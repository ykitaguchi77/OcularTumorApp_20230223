//
//  SendData.swift
//  CorneaApp
//
//  Created by Yoshiyuki Kitaguchi on 2021/04/18.
//
import SwiftUI
import CoreData
import CryptoKit

struct SendData: View {
    @ObservedObject var user: User
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.managedObjectContext) var viewContext
    @State private var showingAlert: Bool = false
        
    var body: some View {
        
        VStack{
                GeometryReader { bodyView in
                    VStack{
                        Text("内容を確認してください").padding().foregroundColor(Color.black)
                            .font(Font.title)
                        
                        ScrollView(.vertical){
                            GetImageStack(images: ResultHolder.GetInstance().GetUIImages(), shorterSide: GetShorterSide(screenSize: bodyView.size))
                        }
                        
                        HStack{
                            Text("撮影日時:")
                            Text(self.user.date, style: .date)
                        }
                        Text("ID: \(self.user.id)")
                        Text("施設: \(self.user.hospitals[user.selected_hospital])")
                        Text("診断名: \(user.disease[user.selected_disease])")
                        Text("自由記載: \(self.user.free_disease)")
                    }
                }

                Spacer()

            
            //送信するとボタンの色が変わる演出
            if self.user.isSendData {
                Button(action: {}) {
                    HStack{
                        Image(systemName: "square.and.arrow.up")
                        Text("送信済み")
                    }
                        .foregroundColor(Color.white)
                        .font(Font.largeTitle)
                }
                    .frame(minWidth:0, maxWidth:CGFloat.infinity, minHeight: 75)
                    .background(Color.blue)
                    .padding()
            } else if (self.user.id.isEmpty || self.user.side[user.selected_side].isEmpty || self.user.hospitals[user.selected_hospital].isEmpty || self.user.disease[user.selected_disease].isEmpty){
                Button(action: {
                    showingAlert = true //空欄があるとエラー
                }) {
                    HStack{
                        Image(systemName: "square.and.arrow.up")
                        Text("送信")
                    }
                        .foregroundColor(Color.white)
                        .font(Font.largeTitle)
                }
                    .alert(isPresented: $showingAlert){Alert(title: Text("項目に空欄があります"))}
                    .frame(minWidth:0, maxWidth:CGFloat.infinity, minHeight: 75)
                    .background(Color.black)
                    .padding()
            } else{
                Button(action: {
                showingAlert = false
                SetCoreData(context: viewContext)
                SaveToResultHolder()
                //SendDataset()
                SaveToDoc()
                self.user.isSendData = true
                self.user.imageNum += 1 //画像番号を増やす
                self.presentationMode.wrappedValue.dismiss()
               })
                {
                    HStack{
                        Image(systemName: "square.and.arrow.up")
                        Text("送信")
                    }
                        .foregroundColor(Color.white)
                        .font(Font.largeTitle)
                }
                .frame(minWidth:0, maxWidth:CGFloat.infinity, minHeight: 75)
                .background(Color.black)
                .padding()
            }
        }
    }
            
    

    
    //ResultHolderにテキストデータを格納
    public func SaveToResultHolder(){
        //var imagenum: String = String(user.imageNum)
        ResultHolder.GetInstance().SetAnswer(q1: self.stringDate(), q2: user.hashid, q3: user.id, q4: self.numToString(num: self.user.imageNum), q5: self.user.side[user.selected_side], q6: self.user.hospitals[user.selected_hospital], q7: self.user.disease[user.selected_disease], q8: user.free_disease)
    }
    
    public func stringDate()->String{
        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd"
        let stringDate = df.string(from: user.date)
        return stringDate
    }
    
    public func numToString(num:Int)->String{
        let string: String = String(num)
        return string
    }

    
    
    
    public func SetCoreData(context: NSManagedObjectContext){
        let newItem = Item(context: viewContext)
        newItem.newdate = self.user.date
        newItem.newid = self.user.id
        newItem.newimagenum = numToString(num: self.user.imageNum)
        newItem.newside = self.user.side[user.selected_side]
        newItem.newhospitals = self.user.hospitals[user.selected_hospital]
        newItem.newdisease = self.user.disease[user.selected_disease]
        newItem.newfreedisease = self.user.free_disease

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateStyle = .medium
        dateFormatter.dateFormat = "yyyyMMdd"
        
        //newdateid: 20211204-11223344-3
        newItem.newdateid = "\(dateFormatter.string(from:self.user.date))-\(self.user.id)-\(self.user.imageNum)"
        let dateid = Data(newItem.newdateid!.utf8)
        let hashid = SHA256.hash(data: dateid)
        
        user.hashid = hashid.compactMap { String(format: "%02x", $0) }.joined()
        print(self.user.hashid)
        newItem.newhashid = self.user.hashid
        
        try! context.save()
        self.user.isNewData = true
        }


    //private func saveToDoc (image: UIImage, fileName: String ) -> Bool{
    public func SaveToDoc () -> Bool{
        let images = ResultHolder.GetInstance().GetUIImages()
        let jsonfile = ResultHolder.GetInstance().GetAnswerJson()
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        //let directory = self.user.hashid+".png"
        let fileURL = documentsURL.appendingPathComponent(self.user.hashid+".png")
        //print(fileURL)
        //pngで保存
        for i in 0..<images.count{
            let pngImageData = UIImage.pngData(images[i])
            // jpgで保存する場合
            // let jpgImageData = UIImageJPEGRepresentation(image, 1.0)
            do {
                try pngImageData()!.write(to: fileURL)
                print("successfully saved PNG to doc")
            } catch {
                //エラー処理
                return false
            }
        
        let fileURL2 = documentsURL.appendingPathComponent(self.user.hashid+".json")
        do {
            try jsonfile.write(to: fileURL2, atomically: true, encoding: String.Encoding.utf8)
            print("successfully saved json to doc")
        } catch {
            //エラー処理
            print("Jsonを保存できませんでした")
            return false
        }
        return true
    }
        
        return true
    }

    public func GetImageStack(images: [UIImage], shorterSide: CGFloat) -> some View {
            let padding: CGFloat = 10.0
            let imageLength = shorterSide / 3 + padding * 2
            let colCount = Int(shorterSide / imageLength)
            let rowCount = Int(ceil(Float(images.count) / Float(colCount)))
            return VStack(alignment: .leading) {
                ForEach(0..<rowCount){
                    i in
                    HStack{
                        ForEach(0..<colCount){
                            j in
                            if (i * colCount + j < images.count){
                                let image = images[i * colCount + j]
                                Image(uiImage: image).resizable().frame(width: imageLength*2.4, height: imageLength*2.4).padding(padding)
                            }
                        }
                    }
                }
            }
            .border(Color.black)
        }
    
    
    public func GetShorterSide(screenSize: CGSize) -> CGFloat{
        let shorterSide = (screenSize.width < screenSize.height) ? screenSize.width : screenSize.height
        return shorterSide
    }
    
}
