
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
                    ForEach(0 ..< items.pq1List.count, id: \.self){idx in
                        HStack{
                            Text("date: \(items.pq1List[idx]), id: \(items.pq3List[idx])-\(items.pq4List[idx]), side: \(items.pq5List[idx]), disease: \(items.pq7List[idx])")
                                
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

    public func getJson()->(pq1List: [String], pq2List: [String], pq3List: [String], pq4List: [String], pq5List: [String], pq6List: [String],pq7List: [String], pq8List: [String], pq9List: [String], pq10List: [String]) {
        //ドキュメントフォルダ内のファイル内容を書き出し
        let documentsURL = NSHomeDirectory() + "/Documents"
        guard let fileNames = try? FileManager.default.contentsOfDirectory(atPath: documentsURL) else {
            print("no files")
            return ([], [], [], [], [], [], [], [], [], [])
        }

        //ファイル内容を1つずつ展開してリストにする
        var contents = [String]()
        var pq1List = [String]()
        var pq2List = [String]()
        var pq3List = [String]()
        var pq4List = [String]()
        var pq5List = [String]()
        var pq6List = [String]()
        var pq7List = [String]()
        var pq8List = [String]()
        var pq9List = [String]()
        var pq10List = [String]()

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

            pq1List.append(jsonData.pq1)
            pq2List.append(jsonData.pq2)
            pq3List.append(jsonData.pq3)
            pq4List.append(jsonData.pq4)
            pq5List.append(jsonData.pq5)
            pq6List.append(jsonData.pq6)
            pq7List.append(jsonData.pq7)
            pq8List.append(jsonData.pq8)
            pq9List.append(jsonData.pq9)
            pq10List.append(jsonData.pq10)
        }
//    print("***** 最終データ確認 *****")
//    print(dateList)
//    print(hashList)
//    print(idList)
//    print(imgNumList)
//    print(sideList)
    return (pq1List, pq2List, pq3List, pq4List, pq5List, pq6List, pq7List, pq8List, pq9List, pq10List)
    }
}


struct JsonData:Codable {  // - Codable に conform
    var pq1: String //date
    var pq2: String //hash
    var pq3: String //id
    var pq4: String //imgNum
    var pq5: String //side
    var pq6: String //hospital
    var pq7: String //disease
    var pq8: String //free
    var pq9: String //sex
    var pq10: String //birthdate
}



