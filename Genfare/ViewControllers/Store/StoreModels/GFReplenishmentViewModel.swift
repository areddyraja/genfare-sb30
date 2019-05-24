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






class GFReplenishmentViewModel {
    let disposebag = DisposeBag()

    
    var designator = ""  //Product Service
    var key12 = "" //Config API
    var beforeEncryptionString = ""
    var walletIdString = "" //Request New Card Service  Hard Coded Plz change
    var agencyIdString = "" //Config ApI
    var signatureStr = ""
    
    func setupIntialValues(){
        designator = UserDefaults.standard.value(forKey: Constants.Replenishment.Designator) as! String
        key12 = UserDefaults.standard.value(forKey: Constants.Replenishment.KEY12) as! String
        let agencyStr = UserDefaults.standard.value(forKey: Constants.Replenishment.AgencyID)
        agencyIdString = String(format: "%4s", self.fillString(data: agencyStr as! String, requiredLength: 4, appendToPrefix: true, withCharacter:"0").utf8EncodedString())

        walletIdString = UserDefaults.standard.value(forKey: Constants.Replenishment.WalletPrintId) as! String
        signatureStr = String(format: "%3s", self.fillString(data: Constants.Replenishment.Signature, requiredLength: 3, appendToPrefix: true, withCharacter: "$").utf8EncodedString())
        if designator.count == 0{
            return
        }
//        let strCRC = self.genericStringForCRC(walletId: walletIdString, agencyId: agencyIdString)
//        let data = self.unlockKey(keyStr: key12 as NSString)
//        print(data)
        self.generateByteData()
        
    }
    func genericStringForCRC(walletId:String,agencyId:String) -> String{
        let replaceStr = "%1s"+"@"+"%51s"+"@"+"%1s"+"@"+"%1s"+"@"+"%6s"
        let strCRC = String(format: replaceStr,
                            self.fillString(data: Constants.Replenishment.FileVersion, requiredLength: 1, appendToPrefix: true, withCharacter: "$").utf8EncodedString(),
            self.fillString(data: walletIdString, requiredLength: 51, appendToPrefix: true, withCharacter: "$").utf8EncodedString(),
            self.fillString(data: Constants.Replenishment.Group, requiredLength: 1, appendToPrefix: true, withCharacter: "$").utf8EncodedString(),
            self.fillString(data: designator, requiredLength: 1, appendToPrefix: true, withCharacter: "$").utf8EncodedString(),
            self.fillString(data: Constants.Replenishment.RFU, requiredLength: 6, appendToPrefix: true, withCharacter: "$").utf8EncodedString()
        )
        return strCRC
    }
    //generateByteData Data for QRCode Image
    func generateByteData(){
//        NSMutableData *beforeEncryptionData=[[NSMutableData alloc] initWithData:fileVersionData];
//        [beforeEncryptionData appendData:[self paddZeroBytes:walletIdString length:51]];
//        [beforeEncryptionData appendData:[self getByteData:groupInt]]; //giving (0x01) series
//        [beforeEncryptionData appendData:[self getByteData:designatorInt]]; //giving (0x01) series
//        [beforeEncryptionData appendData:[self paddZeroBytes:@"" length:6]];
//        NSString *CRC32String = [self GenerateCRCnumberWithNSData:beforeEncryptionData];
//        NSString *CRC32Value = [NSString stringWithFormat:@"%8s",[[self fillString:CRC32String requiredLength:8 appendToPrefix:YES withCharacter:'0'] UTF8String]]; // length 8
//        NSData * lsbData = [self ConvertToLSB:CRC32Value];
//        [beforeEncryptionData appendData:lsbData];
//        NSData * keyData = [self unlockKey:key12];
//        NSData *ivData = NULL;
//        NSData *afterEncryptionData = [beforeEncryptionData AES128EncryptDataWithKey:keyData iv:ivData mode:kCCOptionECBMode];
//        NSString *afterEncodedString = [self convertToBase64EncodedString:afterEncryptionData];
//        NSString * qRCodeString = [NSString stringWithFormat:@"%@%@%@",signature,agencyIdString,afterEncodedString];
//        [self generateQRCodeImage:qRCodeString];
        let fileVersionInt = Int(Constants.Replenishment.FileVersion)
        let groupInt = Int(Constants.Replenishment.Group)
        let designatorInt = Int(designator)
        let fileVersionData = self.getByteData(value: UInt8(fileVersionInt!))
        let beforeEncryptionData:NSMutableData = NSMutableData.init(data: fileVersionData as Data)
        beforeEncryptionData.append(padZeroBytes(str: walletIdString, length: 51) as Data)
        beforeEncryptionData.append(getByteData(value: UInt8(groupInt!)) as Data)
        beforeEncryptionData.append(getByteData(value: UInt8(designatorInt!)) as Data)
        beforeEncryptionData.append(padZeroBytes(str: "", length: 6) as Data)
        let CRC32String:NSString = generateCRCNumberWithData(crcData: beforeEncryptionData as Data) as NSString
        let CRC32Value =  String(format: "%8s",self.fillString(data: CRC32String as String, requiredLength: 8, appendToPrefix: true, withCharacter: "0").utf8EncodedString())
        let lsbData:NSData = self.convertToLSB(crcValue: CRC32Value) as NSData
        beforeEncryptionData.append(lsbData as Data)
        let keyData:NSData = self.unlockKey(keyStr: key12 as NSString) as NSData
        let ivData:NSData = NSData()
//        let afterEncryptionData = beforeEncryptionData ba
//        do {
//            let encrypted = try AES(key: keyDatakey_t, blockMode: CBC(iv: ivData), padding: .pkcs7).encrypt()
//        } catch {
//            print(error)
//        }
        
        
        
        
        
        
        
        
        
    }
    //Integer to NSData
    func intToData(data:NSInteger) -> Data{
//        Byte *byteData = (Byte*)malloc(4);
//        byteData[3] = data & 0xff;
//        byteData[2] = (data & 0xff00) >> 8;
//        byteData[1] = (data & 0xff0000) >> 16;
//        byteData[0] = (data & 0xff000000) >> 24;
//        NSData * result = [NSData dataWithBytes:byteData length:4];
//        return (NSData*)result;
        //TODO ::
        let data = Data()
        return data
    }
    //Converting int to Byte Array Data
    func getByteData(value:UInt8) -> Data{
        
//        Byte *byteData = (Byte*)malloc(64);
//        byteData[0] = intValue;
//        NSData * resultData = [NSData dataWithBytes:byteData length:1];
//        return resultData;
        
        
        let resultData = Data(bytes: [value])
        return resultData
        
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
        var checksum = ""
        checksum = String(decoding: crcData.crc32(), as: UTF8.self)
        return checksum
    }
    //Fill String
    func fillString(data:String,requiredLength:Int,appendToPrefix:Bool,withCharacter:Character) -> String{
       return self.extendString(data: data, requiredLength: requiredLength, char: withCharacter, appendToPrefix: true)
    }
    //Extend method for fillString
    func extendString(data:String,requiredLength:Int,char:Character,appendToPrefix:Bool) -> String{
//
//        char *paddedData = (char *)calloc(requiredLength, sizeof(char));
//        NSUInteger dataLength = [data length];
//        NSUInteger fillCharsLength = requiredLength-dataLength;
//        if (prefix == YES) {
//            for (int i = 0; i < requiredLength; i++) {
//                if (i < fillCharsLength) {
//                    paddedData[i] = character;
//                } else {
//                    paddedData[i] = [data characterAtIndex: i - fillCharsLength];
//                }
//            }
//        }else{
//            for (int i = 0; i < requiredLength; i++) {
//                if (i < dataLength) {
//                    paddedData[i] = [data characterAtIndex:i];
//                } else {
//                    paddedData[i] = character;
//                }
//            }
//        }
//        NSString *paddedString = [[NSString alloc] initWithBytes:paddedData length:requiredLength encoding:NSUTF8StringEncoding];
//        free(paddedData);
//        return paddedString;
        
        
        var paddedData = calloc(requiredLength, MemoryLayout<Int8>.size) as! [Character]
        var dataLength: Int = data.count
        var fillCharsLength: Int = requiredLength - dataLength
        if appendToPrefix == true {
            for i in 0..<requiredLength {
                if i < fillCharsLength {
                    paddedData[i] = char
                } else {
                    paddedData[i] = data[data.index(data.startIndex, offsetBy: UInt(i - fillCharsLength))]
                }
            }
        } else {
            for i in 0..<requiredLength {
                if i < dataLength {
                    paddedData[i] = data[data.index(data.startIndex, offsetBy: UInt(i))]
                } else {
                    paddedData[i] = char
                }
            }
        }
        
        //TODO
        /*
        var paddedString = NSString(data: paddedData as, encoding: String.Encoding.utf8.rawValue)

//        free(paddedData)
        return paddedString */
        
        return ""
    }

    //String to lsb Data
    func convertToLSB(crcValue:String) -> Data{
        
        
//        unsigned result = 0;
//        NSString * crcHexString = [NSString stringWithFormat:@" 0x%@",crcValue];
//        NSScanner *scanner = [NSScanner scannerWithString:crcHexString];
//        [scanner setScanLocation:1]; // bypass '#' character
//        [scanner scanHexInt:&result];
//        //    uint32_t num = result;
//        // Swap endian (big to little) or (little to big)
//        uint32_t num = result;
//        uint32_t b0,b1,b2,b3;
//        uint32_t res;
//        b0 = (num & 0x000000ff) << 24u;
//        b1 = (num & 0x0000ff00) << 8u;
//        b2 = (num & 0x00ff0000) >> 8u;
//        b3 = (num & 0xff000000) >> 24u;
//        res = b0 | b1 | b2 | b3;
//        NSData *lsbData = [self IntToNSData:res];;
//        NSString *lsbString = [NSString stringWithFormat:@"%" PRIX32, res];
//        lsbString = [NSString stringWithFormat:@"%8s",[[self fillString:lsbString requiredLength:8 appendToPrefix:YES withCharacter:'0'] UTF8String]]; // length 8
//        return lsbData;
        
        let result: Int = 0
        let crcHexString = " 0x\(crcValue)"
        let scanner = Scanner(string: crcHexString)
        scanner.scanLocation = 1 // bypass '#' character
//        scanner.scanInt(<#T##result: UnsafeMutablePointer<Int>?##UnsafeMutablePointer<Int>?#>) //// TODO:::
//        var tempresult = &UInt32(result)
//        scanner.scanHexInt32(UInt32(result))
        //    uint32_t num = result;
        // Swap endian (big to little) or (little to big)
        let num = UInt32(result)
        var b0: UInt32 = 0
        var b1: UInt32 = 0
        var b2: UInt32 = 0
        var b3: UInt32 = 0
        var res: UInt32 = 0
        b0 = (num & 0x000000ff) << 24
        b1 = (num & 0x0000ff00) << 8
        b2 = (num & 0x00ff0000) >> 8
        b3 = (num & 0xff000000) >> 24
        res = b0 | b1 | b2 | b3
        let lsbData: Data? = self.intToData(data: NSInteger(res))
        var lsbString = "\(PRIX32)"+"\(res)"
        lsbString = String(format: "%8s", self.fillString(data: lsbString, requiredLength: 8, appendToPrefix: true, withCharacter: "0")).utf8EncodedString()
        return lsbData!
    }


    //String to Data
    func unlockKey(keyStr:NSString) -> Data{
        
//        NSString *command = [keyStr stringByReplacingOccurrencesOfString:@" " withString:@""];
//        command = [command stringByReplacingOccurrencesOfString:@" " withString:@""];
//        NSMutableData *commandToSend= [[NSMutableData alloc] init];
//        unsigned char whole_byte;
//        char byte_chars[3] = {'\0','\0','\0'};
//        int i;
//        for (i=0; i < [command length]/2; i++) {
//            byte_chars[0] = [command characterAtIndex:i*2];
//            byte_chars[1] = [command characterAtIndex:i*2+1];
//            whole_byte = strtol(byte_chars, NULL, 16);
//            [commandToSend appendBytes:&whole_byte length:1];
//        }
//        NSError *error;
//        uint8_t keyiv[] = { 0x31, 0xA9, 0xED, 0xF4, 0x58, 0x21, 0x70, 0xE5, 0x9E, 0x62, 0xBA, 0x04, 0x86, 0xF4, 0x39, 0x41 };
//        uint8_t t_keyKey[] = { 0xEE, 0x20, 0x55, 0x61, 0x23, 0x44, 0xF8, 0x0A, 0x2B, 0x4C, 0x49, 0xBF, 0x92, 0xCA, 0x73, 0x8D };
//        NSData *keykey = [NSData dataWithBytes:t_keyKey length:sizeof(t_keyKey)];
//        NSData * iv_data = [NSData dataWithBytes:keyiv length:sizeof(keyiv)];
//        id<SecretKey> cipherkey = [[AESKey alloc] init:keykey keySize:keykey.length];
//        id<Cipher> cipher = [[AESCipher alloc] init:DECRYPT withKey:cipherkey iv:iv_data];
//        NSMutableData * decry = [NSMutableData data];
//        [decry appendData:[cipher update:commandToSend onError:&error]];
//        [decry appendData:[cipher final:&error]];
//        return decry;
        

        
        let command  = keyStr.replacingOccurrences(of:" ", with:"")
        let modifiedcommand = command.lowercased()
        var spacestr = modifiedcommand.separate(every: 8, with: " ")
        print("modif cmd:\(spacestr)")

        spacestr.insert("<", at: spacestr.startIndex)
        spacestr.insert(">", at: spacestr.endIndex)
        print("spacestr:\(spacestr)")
        let byte_chars:[Character] = ["\0","\0","\0"]
        for  i in 0..<modifiedcommand.count/2{
            
        }
        
     
        let keyiv = [0x31, 0xa9, 0xed, 0xf4, 0x58, 0x21, 0x70, 0xe5, 0x9e, 0x62, 0xba, 0x04, 0x86, 0xf4, 0x39, 0x41]
        var t_keyKey = [0xee, 0x20, 0x55, 0x61, 0x23, 0x44, 0xf8, 0x0a, 0x2b, 0x4c, 0x49, 0xbf, 0x92, 0xca, 0x73, 0x8d]
        var keykey = Data(bytes: t_keyKey, count: t_keyKey.count)
        var iv_data = Data(bytes: keyiv, count: keyiv.count)
        
//        id<SecretKey> cipherkey = [[AESKey alloc] init:keykey keySize:keykey.length];
//        id<Cipher> cipher = [[AESCipher alloc] init:DECRYPT withKey:cipherkey iv:iv_data];
//        NSMutableData * decry = [NSMutableData data];
//        [decry appendData:[cipher update:commandToSend onError:&error]];
//        [decry appendData:[cipher final:&error]];
//        return decry;
        
//        do{
//            let secreykey = try AES.in
//        }catch{
//            
//        }
        



        
        
         
        //// :: TODO
        
//        var command:NSString = keyStr.replacingOccurrences(of: " ", with: "") as! NSString
//        command = command.replacingOccurrences(of: " ", with: "") as NSString
//        var commandToSend = Data()
//        var whole_byte: UInt8 = 0
//        var byte_chars = ["\0", "\0", "\0"]
//        var i: Int = 0
//        for i in 0..<command.length / 2 {
//            byte_chars[0] = (command.character(at: i * 2) as? String)!
//            byte_chars[1] = (command.character(at: (i * 2 + 1)) as? String)!
//            whole_byte = strtol(byte_chars, nil, 16)
//            commandToSend.append(&whole_byte, length: 1)
//        }
//        var error: Error?
//        var keyiv = [0x31, 0xa9, 0xed, 0xf4, 0x58, 0x21, 0x70, 0xe5, 0x9e, 0x62, 0xba, 0x04, 0x86, 0xf4, 0x39, 0x41]
//        var t_keyKey = [0xee, 0x20, 0x55, 0x61, 0x23, 0x44, 0xf8, 0x0a, 0x2b, 0x4c, 0x49, 0xbf, 0x92, 0xca, 0x73, 0x8d]
//        var keykey = Data(bytes: &t_keyKey, length: MemoryLayout<t_keyKey>.size)
//        var iv_data = Data(bytes: &keyiv, length: MemoryLayout<keyiv>.size)
        let data1 = Data()
        return data1
    }
    //Data to String
    func convertToBase64EncodedString(data:Data) -> String{
        let base64EnacodedString = data.base64EncodedString()
        return base64EnacodedString
    }
    //Generating QRCode Image form String
//    func generateQRCodeImage(strInput:String){
//        let qrString = strInput
//        let stringData = qrString.data(using: .utf8)
//        let qrFilter = CIFilter()
//        qrFilter.name = "CIQRCodeGenerator"
//        qrFilter.setValue(stringData, forKey: "inputMessage")
//        qrFilter.setValue("H", forKey: "inputCorrectionLevel")
//        var qrImage = qrFilter.outputImage
//        let scaleX =
//
//
//    }
    
    

}
extension String {
    func separate(every stride: Int = 8, with separator: Character = " ") -> String {
        return String(enumerated().map { $0 > 0 && $0 % stride == 0 ? [separator, $1] : [$1]}.joined())
    }
}

extension String {
    func aesEncrypt(key: String) throws -> String {
        
        var result = ""
        
        do {
            
            let key: [UInt8] = Array(key.utf8) as [UInt8]
            
            let aes = try! AES(key: key, blockMode: ECB() , padding:.pkcs5) // AES128 .ECB pkcs7
            
            let encrypted = try aes.encrypt(Array(self.utf8))
            
            result = encrypted.toBase64()!
            
            
            print("AES Encryption Result: \(result)")
            
        } catch {
            
            print("Error: \(error)")
        }
        
        return result
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
import Foundation

final class CRC32 {
    static let MPEG2 = CRC32(polynomial: 0x04c11db7)
    
    let table: [UInt32]
    
    init(polynomial: UInt32) {
        var table: [UInt32] = [UInt32](repeating: 0x00000000, count: 256)
        for i in 0..<table.count {
            var crc = UInt32(i) << 24
            for _ in 0..<8 {
                crc = (crc << 1) ^ ((crc & 0x80000000) == 0x80000000 ? polynomial : 0)
            }
            table[i] = crc
        }
        self.table = table
    }
    
    func calculate(_ data: Data) -> UInt32 {
        return calculate(data, seed: nil)
    }
    
    func calculate(_ data: Data, seed: UInt32?) -> UInt32 {
        var crc: UInt32 = seed ?? 0xffffffff
        for i in 0..<data.count {
            crc = (crc << 8) ^ table[Int((crc >> 24) ^ (UInt32(data[i]) & 0xff) & 0xff)]
        }
        return crc
    }
}
extension String {
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}
