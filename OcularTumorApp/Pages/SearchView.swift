
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
        
        GeometryReader { bodyView in
            VStack{
        
                Button(action: {
                    items = SearchModel.GetInstance().getJson()
        //            print(items.dateList)
        //            print(items)
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
                List{
                    ForEach(0 ..< items.count, id: \.self){idx in
                        HStack{
                            Text("qaaa")
                                
                            Spacer()
                            Text("Load")
                                .onTapGesture {
                                    print("\(idx)行目のButtonをタップ")
                                }
                                .frame(minWidth:0, maxWidth:bodyView.size.width/4, minHeight: 40)
                                .foregroundColor(Color.white)
                                .background(Color.black)
                        }
                    }
                }
            }
        }
    }
}


//複数のJsonファイルから各項目のリストを作成
class SearchModel: ObservableObject, Identifiable {

    init() {}

    static var instance: SearchModel?
    public static func GetInstance() -> SearchModel{
        if (instance == nil) {
            instance = SearchModel()
        }

        return instance!
    }

    public func getJson() -> [QuestionAnswerData] {
        //ドキュメントフォルダ内のファイル内容を書き出し
        let documentsURL = NSHomeDirectory() + "/Documents"
        guard let fileNames = try? FileManager.default.contentsOfDirectory(atPath: documentsURL) else {
            print("no files")
            return [QuestionAnswerData]() //ファイルが無い場合は空の構造体を返す
        }

        //ファイル内容を1つずつ展開してリストにする
        var contents = [String]()
        var JsonList = [QuestionAnswerData]() //QuestionAnswerDataの構造体定義はResultHolderにある

        for fileName in fileNames {
            try? contents.append(String(contentsOfFile: documentsURL + "/" + fileName, encoding: .utf8))
        }

        //リストを1つずつJson形式にして、その一部をリストの形に戻す
        for num in (0 ..< contents.count) {

            let contentData = contents[num].data(using: .utf8)!
            var appendStr: String = ""

//            print("***** JSONデータ確認 *****")
//            print(String(bytes: contentData, encoding: .utf8)!)

            let decoder = JSONDecoder()
            guard let jsonData: QuestionAnswerData = try? decoder.decode(QuestionAnswerData.self, from: contentData) else {
                fatalError("Failed to decode from JSON.")
            }
            
            JsonList.append(jsonData)
        }
//    print("***** 最終データ確認 *****")
//    print(dateList)
//    print(hashList)
//    print(idList)
//    print(imgNumList)
//    print(sideList)
    return (JsonList)
    }
}


//struct JsonData:Codable {  // - Codable に conform
//    var pq1: String //date
//    var pq2: String //hash
//    var pq3: String //id
//    var pq4: String //imgNum
//    var pq5: String //side
//    var pq6: String //hospital
//    var pq7: String //disease
//    var pq8: String //free
//    var pq9: String //sex
//    var pq10: String //birthdate
//}



