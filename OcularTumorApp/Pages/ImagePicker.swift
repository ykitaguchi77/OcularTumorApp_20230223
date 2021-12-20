//
//  ImagePicker.swift
//  CorneaApp
//
//  Created by Yoshiyuki Kitaguchi on 2021/12/03.
//  https://tomato-develop.com/swiftui-how-to-use-camera-and-select-photos-from-library/
import SwiftUI

struct Imagepicker : UIViewControllerRepresentable {
    @Binding var show:Bool
    @Binding var image:Data

    
    var sourceType:UIImagePickerController.SourceType
 
    func makeCoordinator() -> Imagepicker.Coodinator {
        
        return Imagepicker.Coordinator(parent: self)
    }
      
    func makeUIViewController(context: UIViewControllerRepresentableContext<Imagepicker>) -> UIImagePickerController {
        
        let controller = UIImagePickerController()
        controller.sourceType = sourceType
        controller.delegate = context.coordinator
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<Imagepicker>) {
    }
    
    class Coodinator: NSObject,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

        var parent : Imagepicker
        
        init(parent : Imagepicker){
            self.parent = parent
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            self.parent.show.toggle()
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            let image = info[.originalImage] as! UIImage
            let data = image.pngData()
            self.parent.image = data!
            self.parent.show.toggle()
            
            UIImageWriteToSavedPhotosAlbum(image, nil,nil,nil) //カメラロールに保存
            
            let cgImage = image.cgImage //CGImageに変換
            let cropped = cgImage!.cropToSquare()
            //撮影した画像をresultHolderに格納する
            let imageOrientation = getImageOrientation()
            let rawImage = UIImage(cgImage: cropped).rotatedBy(orientation: imageOrientation)
            setImage(progress: 0, cgImage: rawImage.cgImage!)

        }
        
        //ResultHolderに格納
        public func setImage(progress: Int, cgImage: CGImage){
            ResultHolder.GetInstance().SetImage(index: progress, cgImage: cgImage)
        }
        
    }
}
