
//
//  Informations.swift
//  CorneaApp
//
//  Created by Yoshiyuki Kitaguchi on 2021/04/18.
//
//https://capibara1969.com/3447/
//http://harumi.sakura.ne.jp/wordpress/2019/07/30/document%E3%83%95%E3%82%A9%E3%83%AB%E3%83%80%E3%81%AE%E3%83%95%E3%82%A1%E3%82%A4%E3%83%AB%E5%90%8D%E4%B8%80%E8%A6%A7%E3%82%92%E5%8F%96%E5%BE%97%E3%81%99%E3%82%8B%E9%9A%9B%E3%81%AE%E7%BD%A0/

import SwiftUI
import Foundation

//変数を定義
struct Search: View {
    @ObservedObject var user: User
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var items =  SearchModel.GetInstance().getJson()
    
    var body: some View {
        Button(action: {
            items = SearchModel.GetInstance().getJson()
            }) {
            HStack{
                Image(systemName: "info.circle")
                Text("患者情報入力")
            }
                .foregroundColor(Color.white)
                .font(Font.largeTitle)
            }
            .frame(minWidth:0, maxWidth:CGFloat.infinity, minHeight: 75)
            .background(Color.black)
            .padding()
            .navigationTitle("フォルダ検索")
        
        List(0..<items.count) {(row: Int) in
            Text("\(items[row])")
                .listRowBackground(Color.gray)
        }
    }
}



class SearchModel: ObservableObject, Identifiable {
    
    init() {}
    
    static var instance: SearchModel?
    public static func GetInstance() -> SearchModel{
        if (instance == nil) {
            instance = SearchModel()
        }
        
        return instance!
    }
    
    public func getJson()->[String] {
        //ドキュメントフォルダ内のファイル内容を書き出し
        let documentsURL = NSHomeDirectory() + "/Documents"
        guard let fileNames = try? FileManager.default.contentsOfDirectory(atPath: documentsURL) else {
            print("no files")
            return []
        }
         
        //ファイル内容を1つずつ展開してJsonのリストにする
        var contents = [String]()
        var objList = [String]()
        for fileName in fileNames {
            try? contents.append(String(contentsOfFile: documentsURL + "/" + fileName, encoding: .utf8))
        }
        for num in (0 ..< contents.count) {

            let contentData = contents[num].data(using: .utf8)!
            
            print("***** JSONデータ確認 *****")
            print(String(bytes: contentData, encoding: .utf8)!)
          
            let decoder = JSONDecoder()
            guard let jsonData: QuestionAnswerData = try? decoder.decode(QuestionAnswerData.self, from: contentData) else {
                fatalError("Failed to decode from JSON.")
            }
            objList.append(jsonData.pq2)
        }
    print("***** 最終データ確認 *****")
    print(objList)
    return objList
    }
}






//func getFolder() -> [String] {
//    //ドキュメントフォルダ内のファイル内容を書き出し
//    let documentsURL = NSHomeDirectory() + "/Documents"
//    guard let fileNames = try? FileManager.default.contentsOfDirectory(atPath: documentsURL) else {
//        print("no files")
//        return []
//    }
//
//    //ファイル内容を1つずつ展開してJsonのリストにする
//    var contents = [String]()
//    for fileName in fileNames {
//        try? contents.append(String(contentsOfFile: documentsURL + "/" + fileName, encoding: .utf8))
//    }
    
////////////////////////////////////
//    String形式をdata形式に格納
//    let contentData = contents[0].data(using: .utf8)!
//
//    print("***** JSONデータ確認 *****")
//    print(String(bytes: contentData, encoding: .utf8)!)
//
//    let decoder = JSONDecoder()
//    guard let jsonData: QuestionAnswerData = try? decoder.decode(QuestionAnswerData.self, from: contentData) else {
//        fatalError("Failed to decode from JSON.")
//    }
//    print("***** 最終データ確認 *****")
//    print(jsonData.pq1)
//////////////////////////////////////////
    
//    for num in (0 ..< contents.count) {
//
//        let contentData = contents[num].data(using: .utf8)!
//
//        print("***** JSONデータ確認 *****")
//        print(String(bytes: contentData, encoding: .utf8)!)
//
//        let decoder = JSONDecoder()
//        guard let jsonData: QuestionAnswerData = try? decoder.decode(QuestionAnswerData.self, from: contentData) else {
//            fatalError("Failed to decode from JSON.")
//        }
//        print("***** 最終データ確認 *****")
//        print(jsonData.pq1)
//    }
//
//    return ["aaa"]
//}


struct JsonData:Codable {  // - Codable に conform
    var pq1: String
    var pq2: String
    var pq3: String
    var pq4: String
    var pq5: String
    var pq6: String
    var pq7: String
    var pq8: String
    var pq9: String
    var pq10: String
}



