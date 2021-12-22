//
//  ImagePicker.swift
//  CorneaApp
//
//  Created by Yoshiyuki Kitaguchi on 2021/12/03.
//  https://tomato-develop.com/swiftui-how-to-use-camera-and-select-photos-from-library/
//
// movie acquision:
//https://hatsunem.hatenablog.com/entry/2018/12/04/004823
//https://off.tokyo/blog/how-to-access-info-plist/
//https://ichi.pro/swift-uiimagepickercontroller-250133769115456

import SwiftUI
import UIKit
import AssetsLibrary
import Foundation
import AVKit
import Photos
import AVFoundation

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
        
        //photo, movieモード選択
        controller.mediaTypes = ["public.image", "public.movie"]
        //controller.mediaTypes = ["public.image"]
        controller.cameraCaptureMode = .photo // Default media type .photo vs .video
        controller.videoQuality = .typeHigh
        controller.cameraFlashMode = .on
        controller.cameraDevice = .rear //or front
        controller.allowsEditing = false
        
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
            
            // Check for the media type
            if let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String {

                if mediaType  == "public.image" {
                    print("Image Selected")
                    
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
                    ResultHolder.GetInstance().SetImage(index: 0, cgImage: rawImage.cgImage!)
                    //setImage(progress: 0, cgImage: rawImage.cgImage!)
                }

                if mediaType == "public.movie" {
                    print("Video Selected")
                    
                    // get a URL for the selected local file with nil safety
                    guard let mediaUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL else { return }
                    self.parent.show.toggle()
                    
                    print(mediaUrl)
                    
                    let tempDirectory: URL = URL(fileURLWithPath: NSTemporaryDirectory())
                    let croppedMovieFileURL: URL = tempDirectory.appendingPathComponent("mytemp2.mov")
                    
                    MovieCropper.exportSquareMovie(sourceURL: mediaUrl, destinationURL: croppedMovieFileURL, fileType: .mov, completion: {
                        // 正方形にクロッピングされた動画をフォトライブラリに保存
                        self.saveToPhotoLibrary(fileURL: croppedMovieFileURL)
                    })
                  
                    
                    //カメラロールに保存
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: mediaUrl)
                             })
                    ////撮影した動画をresultHolderに格納する
                    ResultHolder.GetInstance().SetMovieUrls(Url: mediaUrl.absoluteString)

                    // Save movie to album


                    }
                }

    
            }
        func saveToPhotoLibrary(fileURL: URL) {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileURL)
            }) { saved, error in
                let success = saved && (error == nil)
                let title = success ? "Success" : "Error"
                let message = success ? "Video saved." : "Failed to save video."
                
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
            }
        }
        
//        //ResultHolderに格納
//        public func setImage(progress: Int, cgImage: CGImage){
//            ResultHolder.GetInstance().SetImage(index: progress, cgImage: cgImage)
//        }
//

        
    }
}
