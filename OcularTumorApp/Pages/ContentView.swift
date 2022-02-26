//
//  ContentView.swift
//  CorneaApp
//
//  Created by Yoshiyuki Kitaguchi on 2021/04/18.
//
//写真Coredata参考サイト：https://tomato-develop.com/swiftui-camera-photo-library-core-data/
//
import SwiftUI
import CoreData

//変数を定義
class User : ObservableObject {
    @Published var date: Date = Date()
    @Published var id: String = ""
    @Published var hashid: String = ""
    @Published var selected_side: Int = 0
    @Published var selected_hospital: Int = 0
    @Published var selected_disease: Int = 0
    @Published var free_disease: String = ""
    @Published var side: [String] = ["", "右", "左"]
    @Published var hospitals: [String] = ["", "筑波大", "大阪大", "東京歯科大市川", "鳥取大", "宮田眼科", "順天堂大", "ツカザキ病院", "広島大", "新潟大", "富山大", "福島県立医大", "東京医大"]
    @Published var disease: [String] = ["", "正常", "", "<<結膜良性腫瘍>>", "翼状片", "偽翼状片", "瞼裂斑", "結膜母斑", "結膜色素沈着（非腫瘍性）", "結膜色素沈着（非腫瘍性）", "結膜下出血", "結膜嚢胞", "血管腫", "肉芽腫", "結膜良性腫瘍その他","", "<<結膜悪性腫瘍>>", "結膜扁平上皮癌", "結膜悪性黒色腫", "結膜悪性リンパ腫", "結膜上皮内新生物", "結膜悪性腫瘍その他", "", "<<眼瞼良性腫瘍>>", "霰粒腫", "麦粒腫", "眼瞼母斑", "脂漏性角化症", "乳頭腫", "血管腫", "肉芽腫", "マイボーム腺嚢胞","眼瞼良性腫瘍その他","", "<<眼瞼悪性腫瘍>>","脂腺癌", "扁平上皮癌", "基底細胞癌", "眼瞼悪性腫瘍その他", "", "分類不能（自由記載）"]
    @Published var imageNum: Int = 0 //写真の枚数（何枚目の撮影か）
    @Published var isNewData: Bool = false
    @Published var isSendData: Bool = false
    }


struct ContentView: View {
    @ObservedObject var user = User()
    //CoreDataの取り扱い
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.newdate, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    @State private var goTakePhoto: Bool = false  //撮影ボタン
    @State private var isPatientInfo: Bool = false  //患者情報入力ボタン
    @State private var goSendData: Bool = false  //送信ボタン
    @State private var savedData: Bool = false  //送信ボタン
    @State private var newPatient: Bool = false  //送信ボタン
    
    
    var body: some View {
        VStack(spacing:0){
            Text("Ocular tumor app")
                .font(.largeTitle)
                .padding(.bottom)
            
            Image("IMG_1273")
                .resizable()
                .scaledToFit()
                .frame(width: 200)
            
            Button(action: {
                //病院番号はアプリを落としても保存されるようにしておく
                self.user.selected_hospital = UserDefaults.standard.integer(forKey: "hospitaldefault")
                self.isPatientInfo = true /*またはself.show.toggle() */
                
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
            .sheet(isPresented: self.$isPatientInfo) {
                Informations(user: user)
                //こう書いておかないとmissing as ancestorエラーが時々でる
            }
            
            Button(action: {
                self.goTakePhoto = true /*またはself.show.toggle() */
                self.user.isSendData = false //撮影済みを解除
                ResultHolder.GetInstance().SetMovieUrls(Url: "")  //動画の保存先をクリア
            }) {
                HStack{
                    Image(systemName: "camera")
                    Text("撮影")
                }
                    .foregroundColor(Color.white)
                    .font(Font.largeTitle)
            }
                .frame(minWidth:0, maxWidth:CGFloat.infinity, minHeight: 75)
                .background(Color.black)
                .padding()
            .sheet(isPresented: self.$goTakePhoto) {
                CameraPage(user: user)
            }
            

            //送信するとボタンの色が変わる演出
            if self.user.isSendData {
                Button(action: {self.goSendData = true /*またはself.show.toggle() */}) {
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
                .sheet(isPresented: self.$goSendData) {
                    SendData(user: user)
                }
            } else {
                Button(action: { self.goSendData = true /*またはself.show.toggle() */ }) {
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
                .sheet(isPresented: self.$goSendData) {
                    SendData(user: user)
                }
            }
            
            HStack{
            Button(action: { self.savedData = true /*またはself.show.toggle() */ }) {
                HStack{
                    Image(systemName: "folder")
                    Text("リスト")
                }
                    .foregroundColor(Color.white)
                    .font(Font.largeTitle)
            }
                .frame(minWidth:0, maxWidth:200, minHeight: 75)
                .background(Color.black)
                .padding()
            .sheet(isPresented: self.$savedData) {
                SavedData(user: user)
            }
            
            Button(action: { self.newPatient = true /*またはself.show.toggle() */ }) {
                HStack{
                    Image(systemName: "stop.circle")
                    Text("次患者")
                }
                    .foregroundColor(Color.white)
                    .font(Font.largeTitle)
            }
            .alert(isPresented:$newPatient){
                Alert(title: Text("データをクリアしますか？"), primaryButton:.default(Text("はい"),action:{
                    //データの初期化
                    self.user.date = Date()
                    self.user.id = ""
                    self.user.imageNum = 0
                    self.user.selected_side = 0
                    self.user.selected_hospital = 0
                    self.user.selected_disease = 0
                    self.user.free_disease = ""
                    self.user.isSendData = false
                    
                }),
                      secondaryButton:.destructive(Text("いいえ"), action:{}))
                }
                .frame(minWidth:0, maxWidth:200, minHeight: 75)
                .background(Color.black)
                .padding()
            }
        }
    }
}
