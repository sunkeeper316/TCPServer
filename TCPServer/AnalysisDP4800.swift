import Foundation

public class AnalysisDP4800 : NSObject {
    static var stringBuffer = ""
    
    public static func analysisResult(dataBuffer : String)  {
        stringBuffer = stringBuffer + dataBuffer
        if stringBuffer.contains("}"){
            let strList = stringBuffer.split(separator: "\r\n")
            for str in strList {
                if str.contains("{") && str.contains("}") {
                    if let jsonData = str.data(using: .utf8) {
                        let decoder = JSONDecoder()
                        if let getResult = try? decoder.decode(GetResult.self, from: jsonData){
                            for p in getResult.packet ?? [] {
                                print(p.net_weight)
                            }
                        }
                    }
                }
            }
        }
    }
}
//
//import Foundation
//
//public class AnalysisDP4800 : NSObject {
//
//    static var stringBuffer = ""
//    static var maxStringCount = 65535
//
//    var model : String?
//    var sn : String?
//    var echo : String?
//
//    public func getModel() -> String? {
//        return self.model
//    }
//
//    public func getSN() -> String? {
//        return self.sn
//    }
//    public func getEcho() -> String? {
//        return self.echo
//    }
//    public func AnalysisSplit(strData : String) -> AnalysisErrorCode {
//        for value in Command.allCases {
//            if strData.contains(value.rawValue) {
//                echo = strData
//                return .AnalysisOK
//            }
//        }
//
//        return .CommandFormatError
//    }
//
//    public static func isCanAnalysis() -> Bool{
//        if stringBuffer.contains("CT+CMD") && stringBuffer.contains("\r\n") {
//            return true
//        }else if stringBuffer.contains("{") && stringBuffer.contains("}"){
//            return true
//        }else{
//            return false
//        }
//    }
//    static func getDecimalNumber(number:String) -> Int{
//
//        let nStrList = number.components(separatedBy: ".")
//        if nStrList.count > 1 {
//            return nStrList[1].count
//        }
//        return 0
//    }
//    static func getNumber(strings:String) -> String{
//        var number = ""
//        for string in strings {
//            if string.asciiValue! >= UInt8(48) && string.asciiValue! <= UInt8(57) || string.asciiValue! == UInt8(46) {
//                number.append(string)
//            }
//        }
//        return number
//    }
//    public static func analysisResult(dataBuffer : [UInt8]) -> (analysisStatus : AnalysisErrorCode , echo : String? ,analysisObject : GetResult?) {
//        if self.stringBuffer.count > maxStringCount {
//            if !self.stringBuffer.contains("CT+CMD") && !self.stringBuffer.contains("{") && !stringBuffer.contains("}") {
//                self.stringBuffer = ""
//            }
//        }
//        let date = dataBuffer.filter { (e) -> Bool in
//            return e > 0
//        }
//        if let stringBuffer = String(bytes: date, encoding: .ascii) {
//            self.stringBuffer = self.stringBuffer + stringBuffer
//        }
//        if self.stringBuffer.contains("\r\n") {
//            var result : GetResult?
//            var echo : String?
//            var analysisErrorCode : AnalysisErrorCode = .AnalysisNoReady
//            let strList = stringBuffer.split(separator: "\r\n")
//
//            if let dataStr = strList.first {
//                if (dataStr.contains("{")){
//                    print(dataStr)
//                    if let jsonData = dataStr.data(using: .utf8) {
////                        print(jsonData)
//                        let decoder = JSONDecoder()
//                        if let getResult = try? decoder.decode(GetResult.self, from: jsonData){
////                            print(getResult.title)
//                            result = getResult
//                            for p in result?.packet ?? [] {
//                                if let weight = p.net_weight {
//                                    let number = getNumber(strings: String(weight))
//
//                                    p.decimalNumber = getDecimalNumber(number: number)
//                                }
//                            }
////                            if let weight = result?.packet?.first?.net_weight{
////                                print(weight)
////                                let number = getNumber(strings: String(weight))
////
////                                result?.decimalNumber = getDecimalNumber(number: number)
////                                print(number)
////                                print(result?.decimalNumber)
////                            }
//                            analysisErrorCode = .AnalysisOK
//                        }else{
//                            analysisErrorCode = .AnalysisError
//                            print("decoder Error")
//                            return (analysisErrorCode ,echo, result)
//                        }
//                    }else{
//                        analysisErrorCode = .AnalysisError
//                        return (analysisErrorCode ,echo, result)
//                    }
//
//                }else if dataStr.contains("CT+CMD"){
//                    analysisErrorCode = .AnalysisOK
//                    echo = String(dataStr)
////                    print(dataStr)
//                }
//            }
//
//            if (strList.count > 1){
//                var newStr = ""
//                for ( index,s )in strList.enumerated() {
//                    if index != 0 {
//                        newStr += s
//                    }
//                }
//                self.stringBuffer = newStr
//            }else{
//                self.stringBuffer = ""
//            }
//            return (analysisErrorCode ,echo, result)
//        }
//        return (.AnalysisNoReady ,nil, nil)
//    }
//
//
//}
