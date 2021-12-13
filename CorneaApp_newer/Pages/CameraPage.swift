//
//  ContentView.swift
//  Shared
//
//  Created by Kuniaki Ohara on 2021/01/06.
//

import SwiftUI

struct CameraPage: View {
    
    @ObservedObject var user: User
    @State var imageData : Data = .init(capacity:0)
    @State var rawImage : Data = .init(capacity:0)
    @State var source:UIImagePickerController.SourceType = .camera

    @State var isActionSheet = true
    @State var isImagePicker = true
    

    
    var body: some View {
            NavigationView{
                VStack(spacing:0){
                        ZStack{
                            NavigationLink(
                                destination: Imagepicker(show: $isImagePicker, image: $imageData,  sourceType: source),
                                isActive:$isImagePicker,
                                label: {
                                    Text("TakePhoto")
                                })
                            VStack{
                                if imageData.count != 0{
                                    SendData(user:user)
                                    
                            }
                        }
                }
                .navigationBarTitle("", displayMode: .inline)
            }
        .ignoresSafeArea(.all, edges: .top)
        .background(Color.primary.opacity(0.06).ignoresSafeArea(.all, edges: .all))
    }
    
    
}

}
