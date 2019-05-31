		//
//  GFReplenishmentViewModel.swift
//  Genfare
//
//  Created by OmniTech on 17/05/19.
//  Copyright © 2019 Omniwyse. All rights reserved.
//

import UIKit
import RxSwift
import CommonCrypto
import CryptoSwift




enum Operation {
    case encrypt
    case decrypt
}
class GFReplenishmentViewModel{
    let disposebag = DisposeBag()
    private let keySizeAES128 = 16
    private let aesBlockSize = 16


    
    var designator = ""  //Product Service
    var key12 = "" //Config API
    var beforeEncryptionString = ""
    var walletIdString = "" //Request New Card Service  Hard Coded Plz change
    var agencyIdString = "" //Config ApI
    var signatureStr = ""
    
    func getQRImage() -> UIImage{
        let qrcodestring = setupIntialValues()
        let qrcodeimage  = generateImage(qrcodestr: qrcodestring)
        return qrcodeimage
    }
    
    func setupIntialValues() -> String{
        var qrcodestr = ""
        designator = UserDefaults.standard.value(forKey: Constants.Replenishment.Designator) as! String
        key12 = UserDefaults.standard.value(forKey: Constants.Replenishment.KEY12) as! String
        if let agencyStr = UserDefaults.standard.value(forKey: Constants.Replenishment.AgencyID){
            agencyIdString = fillString(data: "\(agencyStr)", requiredLength: 4, appendToPrefix: true, withCharacter:"0").utf8DecodedString()
        }
        print("=======\(agencyIdString)")
        signatureStr = fillString(data: Constants.Replenishment.Signature, requiredLength: 3, appendToPrefix: true, withCharacter: "$").utf8DecodedString()
        walletIdString = UserDefaults.standard.value(forKey: Constants.Replenishment.WalletPrintId) as! String
        if designator.count == 0{
            return ""
        }
        let strCRC = self.genericStringForCRC(walletId: walletIdString, agencyId: agencyIdString).utf8DecodedString()
        print("strCRC is:\(strCRC)")
        qrcodestr = self.generateByteData()
        return qrcodestr
    }
    func generateImage(qrcodestr:String) -> UIImage{
        print("Final qrcode string:\(qrcodestr)")
        let strdata = qrcodestr.data(using: String.Encoding.utf8)
        let qrFilter = CIFilter(name: "CIQRCodeGenerator")
        qrFilter?.setValue(strdata, forKey: "inputMessage")
        qrFilter?.setValue("H", forKey: "inputCorrectionLevel")
        guard let qrImage = qrFilter?.outputImage else{
            return UIImage.init(named: "")!
        }
        return UIImage.init(ciImage: qrImage)
    }
    func genericStringForCRC(walletId:String,agencyId:String) -> String{
        
        let strone  = fillString(data: Constants.Replenishment.FileVersion, requiredLength: 1, appendToPrefix: true, withCharacter: "$").utf8EncodedString()
        let strtwo  = fillString(data: walletIdString, requiredLength: 51, appendToPrefix: true, withCharacter: "$").utf8EncodedString()
        let strthree  = fillString(data: Constants.Replenishment.Group, requiredLength: 1, appendToPrefix: true, withCharacter: "$").utf8EncodedString()
        let strfour  = fillString(data: designator, requiredLength: 1, appendToPrefix: true, withCharacter: "$").utf8EncodedString()
        let strfive  = fillString(data: Constants.Replenishment.RFU, requiredLength: 6, appendToPrefix: true, withCharacter: "$").utf8EncodedString()
        
        return strone + strtwo + strthree + strfour + strfive
        
    }
    //generateByteData Data for QRCode Image
    func generateByteData() -> String{
        
        let fileVersionInt = UInt8(Constants.Replenishment.FileVersion)
        let groupInt = UInt8(Constants.Replenishment.Group)
        let designatorInt = UInt8(designator)
        guard let fileVersionData = fileVersionInt?.data else{
            return ""
        }
        guard let groupintdata = groupInt?.data else{
            return ""
        }
        guard let designatordata = designatorInt?.data else{
            return ""
        }
        let beforeEncryptionData:NSMutableData = NSMutableData.init(data:fileVersionData)
        beforeEncryptionData.append(padZeroBytes(str: walletIdString, length: 51) as Data)
        beforeEncryptionData.append(groupintdata)
        beforeEncryptionData.append(designatordata)
        beforeEncryptionData.append(padZeroBytes(str: "", length: 6) as Data)
        let CRC32String = generateCRCNumberWithData(crcData: beforeEncryptionData as Data)
        let CRC32Value =  fillString(data: CRC32String, requiredLength: 8, appendToPrefix: true, withCharacter: "0").utf8DecodedString()
        let lsbData = convertToLSB(crc32value: CRC32Value)
        beforeEncryptionData.append(lsbData)
        guard let keyDataBytes = self.unlockKey(keyStr: (key12 as NSString) as String) as? [UInt8] else{
            return ""
        }
        let finalapenddata = beforeEncryptionData as Data
        let keydata = Data(bytes: keyDataBytes)
        let ivdata = Data()
        let encrypteddata = aes128Encrypt(data: finalapenddata, keyData: keydata, ivData: ivdata, operation: 0)
        let justforprinting: NSData = encrypteddata as NSData
        print("Mutable data:\(justforprinting)")
        let afterencodedString  = convertToBase64EncodedString(data: encrypteddata)
        let qrcodestring = signatureStr + agencyIdString + afterencodedString;
        return qrcodestring

    }
    func aes128Encrypt(data:Data, keyData:Data, ivData:Data, operation:Int) -> Data {
        let cryptLength  = size_t(data.count + kCCBlockSizeAES128)
        var cryptData = Data(count:cryptLength)
        
        let keyLength             = size_t(kCCKeySizeAES128)
        let options   = CCOptions(kCCOptionECBMode)
        
        
        var numBytesEncrypted :size_t = 0
        
        let cryptStatus = cryptData.withUnsafeMutableBytes {cryptBytes in
            data.withUnsafeBytes {dataBytes in
                ivData.withUnsafeBytes {ivBytes in
                    keyData.withUnsafeBytes {keyBytes in
                        CCCrypt(CCOperation(operation),
                                CCAlgorithm(kCCAlgorithmAES),
                                options,
                                keyBytes, keyLength,
                                ivBytes,
                                dataBytes, data.count,
                                cryptBytes, cryptLength,
                                &numBytesEncrypted)
                    }
                }
            }
        }
        
        if UInt32(cryptStatus) == UInt32(kCCSuccess) {
            cryptData.removeSubrange(numBytesEncrypted..<cryptData.count)
            
        } else {
            print("Error: \(cryptStatus)")
        }
        
        return cryptData;
    }

    func convertToLSB(crc32value:String) -> Data{
        
        let hex = crc32value
        var result:UInt32 = 0
        Scanner(string: hex).scanHexInt32(&result)
        
        let num = UInt32(result)
        var b0: UInt32
        var b1: UInt32
        var b2: UInt32
        var b3: UInt32
        var res: UInt32
        b0 = (num & 0x000000ff) << 24
        b1 = (num & 0x0000ff00) << 8
        b2 = (num & 0x00ff0000) >> 8
        b3 = (num & 0xff000000) >> 24
        res = b0 | b1 | b2 | b3
        
        guard let lsbdata:Data = res.data else{
            return Data()
        }
        return Data(bytes: lsbdata.reversed())
        
    }
    //Padding with Zero Bytes
    func padZeroBytes(str:String,length:Int) -> NSMutableData{
        let tdata: NSData? = (str.data(using: .utf8, allowLossyConversion: true)! as NSData)
        let data = NSMutableData(bytes: tdata?.bytes, length: tdata?.length ?? 0)
        data.increaseLength(by: length - (tdata?.length ?? 0))
        return data
    }
    //CRC Data to CRC Number in String format
    func generateCRCNumberWithData(crcData:Data) -> String{
        guard let checksum  = crcData.stringUTF8 else{
            return ""
        }
        return checksum.crc32()
    }
    //Fill String
    func fillString(data:String,requiredLength:Int,appendToPrefix:Bool,withCharacter:Character) -> String{
       return self.extendString(data: data, requiredLength: requiredLength, char: withCharacter, appendToPrefix: appendToPrefix)
    }
    //Extend method for fillString
    func extendString(data:String,requiredLength:Int,char:Character,appendToPrefix:Bool) -> String{
        
        var fillstring = ""

        if data.count >= requiredLength{
            return data
        }
        let noOfLoops = requiredLength - data.count
        if appendToPrefix == true{
            noOfLoops.times {
                fillstring += "\(char)"
            }
            fillstring += data
        }else{
            fillstring = "\(data)"
            noOfLoops.times {
                fillstring  += "\(char)"
            }
        }
        
        let extendedstring = NSString(bytes: fillstring.bytes, length: requiredLength, encoding:String.Encoding.utf8.rawValue)! as String
        return extendedstring

    }

    func stringToBytes(_ string: String) -> [UInt8] {
        let length = string.count
        var bytes = [UInt8]()
        bytes.reserveCapacity(length/2)
        var index = string.startIndex
        for _ in 0..<length/2 {
            let nextIndex = string.index(index, offsetBy: 2)
            if let b = UInt8(string[index..<nextIndex], radix: 16) {
                bytes.append(b)
            } else {
                return []
            }
            index = nextIndex
        }
        return bytes
    }
    //String to Data
    func unlockKey(keyStr:String) -> [UInt8]{
        
        let data  = [UInt8]()
        let command  = keyStr.replacingOccurrences(of:" ", with:"")
        let commandToSend = self.stringToBytes(command)
 
        let keyiv:[UInt8] = [0x31, 0xa9, 0xed, 0xf4, 0x58, 0x21, 0x70, 0xe5, 0x9e, 0x62, 0xba, 0x04, 0x86, 0xf4, 0x39, 0x41]
        let t_keyKey:[UInt8] = [0xee, 0x20, 0x55, 0x61, 0x23, 0x44, 0xf8, 0x0a, 0x2b, 0x4c, 0x49, 0xbf, 0x92, 0xca, 0x73, 0x8d]
 
        do {
            let decrypteddata = try AES(key: t_keyKey, blockMode: CBC(iv: keyiv), padding: .pkcs7).decrypt(commandToSend)
            return decrypteddata
        } catch {
            print(error)
        }
        return data
  
    }
    //Data to String
    func convertToBase64EncodedString(data:Data) -> String{
        let base64EnacodedString = data.base64EncodedString()
        return base64EnacodedString
    }

}


extension String{
    func utf8DecodedString()-> String {
        let data = self.data(using: .utf8)
        if let message = String(data: data!, encoding: .nonLossyASCII){
            return message
        }
        return ""
    }
    
    func utf8EncodedString()-> String {
        let messageData = self.data(using: .nonLossyASCII)
        let text = String(data: messageData!, encoding: .utf8)
        return text!
    }

}
        
extension Int {
    func times(_ f: () -> ()) {
                if self > 0 {
                    for _ in 0..<self {
                        f()
                    }
                }
    }
            
}
        
 
