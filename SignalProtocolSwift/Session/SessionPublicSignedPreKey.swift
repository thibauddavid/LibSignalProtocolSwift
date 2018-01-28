//
//  SessionPublicSignedPreKey.swift
//  SignalProtocolSwift iOS
//
//  Created by User on 27.01.18.
//  Copyright © 2018 User. All rights reserved.
//

import Foundation


/**
 A public signed pre key is used as part of a session bundle to establish a new session.
 The public part of the key pair is signed with the identity key of the creator
 to provide authentication.
 */
public struct SessionPublicSignedPreKey {

    /// The id of the signed pre key
    public let id: UInt32

    /// The key pair of the signed pre key
    public let key: PublicKey

    /// The time when the key was created
    public let timestamp: UInt64

    /// The signature of the public key of the key pair
    public let signature: Data

    /**
     Create a public signed pre key from its components.
     - parameter id: The id of the signed pre key
     - parameter key: The public key of the signed pre key
     - parameter timestamp: The time when the key was created
     - parameter signature: The signature of the public key of the key pair
     */
    init(id: UInt32, timestamp: UInt64, key: PublicKey, signature: Data) {
        self.id = id
        self.key = key
        self.timestamp = timestamp
        self.signature = signature
    }

    /**
     Create a public signed pre key from the complete signed pre key.
     - parameter signedPreKey: The signed pre key
     */
    init(signedPreKey: SessionSignedPreKey) {
        self.id = signedPreKey.id
        self.key = signedPreKey.keyPair.publicKey
        self.timestamp = signedPreKey.timestamp
        self.signature = signedPreKey.signature
    }
}

// MARK: Protocol Buffers

extension SessionPublicSignedPreKey {

    /**
     Create a signed pre key from serialized data.
     - parameter data: The serialized record.
     - throws: `SignalError` of type `invalidProtoBuf` if data is corrupt or missing
     */
    public init(from data: Data) throws {
        let object: Textsecure_SignedPreKeyRecordStructure
        do {
            object = try Textsecure_SignedPreKeyRecordStructure(serializedData: data)
        } catch {
            throw SignalError(.invalidProtoBuf, "Could not deserialize SessionSignedPreKey ProtoBuf object: \(error)")
        }
        try self.init(from: object)
    }

    /**
     Create a signed pre key from a ProtoBuf object.
     - parameter object: The ProtoBuf object.
     - throws: `SignalError` of type `invalidProtoBuf` if data is corrupt or missing
     */
    init(from object: Textsecure_SignedPreKeyRecordStructure) throws {
        guard object.hasID, object.hasPublicKey,
            object.hasSignature, object.hasTimestamp else {
                throw SignalError(.invalidProtoBuf, "Missing data in SessionSignedPreKey object")
        }
        self.id = object.id
        self.key = try PublicKey(from: object.publicKey)
        self.timestamp = object.timestamp
        self.signature = object.signature
    }

    /// Convert the public signed pre key to a ProtoBuf object
    var object: Textsecure_SignedPreKeyRecordStructure {
        return Textsecure_SignedPreKeyRecordStructure.with {
            $0.id = self.id
            $0.publicKey = self.key.data
            $0.timestamp = self.timestamp
            $0.signature = self.signature
        }
    }

    /**
     Convert the signed pre key to serialized data.
     - returns: The serialized record.
     - throws: `SignalError` of type `invalidProtoBuf`
     */
    public func data() throws -> Data {
        do {
            return try object.serializedData()
        } catch {
            throw SignalError(.invalidProtoBuf, "Could not serialize SessionSignedPreKey ProtoBuf object: \(error)")
        }
    }
}

extension SessionPublicSignedPreKey: Equatable {

    /**
     Compare two public signed pre keys for equality.
     - parameters lhs: The first public signed pre key
     - parameters rhs: The second public signed pre key
     - returns: `True`, if the public signed pre keys match
     */
    public static func ==(lhs: SessionPublicSignedPreKey, rhs: SessionPublicSignedPreKey) -> Bool {
        return lhs.id == rhs.id &&
            lhs.key == rhs.key &&
            lhs.signature == rhs.signature &&
            lhs.timestamp == rhs.timestamp
    }
}