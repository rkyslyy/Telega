//
//  EncryptionService.swift
//  Telega
//
//  Created by Roman Kyslyy on 2/20/19.
//  Copyright © 2019 Roman Kyslyy. All rights reserved.
//

import SwiftyRSA

class EncryptionService {

  // Methods
  class func getStringPemsUsing(
    encryptionKey: String
    ) -> (publicPem: String, privatePem: String)? {
    guard let keyPair = getStringKeyPair() else { return nil }
    return (
      publicPem: keyPair.publicPem,
      privatePem: encryptString(
        string: keyPair.privatePem,
        encryptionKey: encryptionKey))
  }

  private class func getStringKeyPair(
    ) -> (publicPem: String, privatePem: String)? {
    do {
      let keyPair = try SwiftyRSA.generateRSAKeyPair(sizeInBits: 2048)
      let publicPem = try keyPair.publicKey.pemString()
      let privatePem = try keyPair.privateKey.pemString()
      return (publicPem: publicPem, privatePem: privatePem)
    } catch {
      return nil
    }
  }

  class func publicKeyFrom(base64String: String) -> PublicKey? {
    do {
      return try PublicKey(pemEncoded: base64String)
    } catch {
      print("could not get public key")
      return nil
    }
  }

  class func encryptString(string: String, encryptionKey: String) -> String {
    let messageData = string.data(using: .utf8)!
    let cipherData = RNCryptor.encrypt(
      data: messageData,
      withPassword: encryptionKey)
    return cipherData.base64EncodedString()
  }

  class func decryptString(
    encryptedString: String,
    encryptionKey: String
    ) -> String? {
    do {
      let encryptedData = Data.init(base64Encoded: encryptedString)!
      let decryptedData = try RNCryptor.decrypt(
        data: encryptedData,
        withPassword: encryptionKey)
      let decryptedString = String(
        data: decryptedData,
        encoding: .utf8)!
      return decryptedString
    } catch {
      return nil
    }
  }

  class func decryptedMessage(_ message: String) -> String {
    do {
      let encrypted = try EncryptedMessage(base64Encoded: message)
      let privateKey = try PrivateKey(
        pemEncoded: DataService.instance.privatePem!)
      let decrypted = try encrypted.decrypted(
        with: privateKey,
        padding: .PKCS1)
      let decryptedMessage = try decrypted.string(encoding: .utf8)
      return decryptedMessage
    } catch {
      return "Bad decryption"
    }
  }

  class func encryptedMessages(
    _ message: String,
    withPublicKey publicKey: PublicKey
    ) -> (encForMe: String, encForComp: String)? {
    do {
      let trimmedText = message.trimmingCharacters(
        in: .whitespacesAndNewlines)
      let clear = try ClearMessage(string: trimmedText, using: .utf8)
      let encryptedForCompanion = try clear.encrypted(
        with: publicKey,
        padding: .PKCS1)
      let encryptedForMe = try clear.encrypted(
        with: DataService.instance.publicKey!,
        padding: .PKCS1)
      return (
        encForMe: encryptedForMe.base64String,
        encForComp: encryptedForCompanion.base64String)
    } catch { return nil }
  }
}
