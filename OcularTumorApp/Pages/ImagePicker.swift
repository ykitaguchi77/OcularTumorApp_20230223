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
//正方形動画撮影　https://superhahnah.com/swift-square-av-capture/

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
        
        //overlay image
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = min(screenSize.width, screenSize.height)
        let screenHeight = min(screenSize.width, screenSize.height)
//        controller.cameraOverlayView = CircleView(frame: CGRect(x: (screenWidth / 2) - 50, y: (screenWidth / 2) + 25, width: 100, height: 100))
        controller.cameraOverlayView = RectangleView(frame: CGRect(x: 0, y: screenWidth / 8, width: screenWidth, height: screenHeight))
        
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

                    print(mediaUrl)
                    
                    let tempDirectory: URL = URL(fileURLWithPath: NSTemporaryDirectory())
                    let croppedMovieFileURL: URL = tempDirectory.appendingPathComponent("mytemp2.mov")
                    

                    MovieCropper.exportSquareMovie(sourceURL: mediaUrl, destinationURL: croppedMovieFileURL, fileType: .mov, completion: {
                        // 正方形にクロッピングされた動画をフォトライブラリに保存
                        self.saveMovieToPhotoLibrary(fileURL: croppedMovieFileURL)
                        self.saveToResultHolder(fileURL: croppedMovieFileURL)
                    })
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        // 1秒後に実行したいコードを書く

                        //temporary pathにサムネイルを保存
                        let thumbnailImage = self.thumnailImageForFileUrl(fileUrl: croppedMovieFileURL)?.cgImage
                        //サムネイルをresultHolderに格納
                        do{
                            let rawImage = try UIImage(cgImage: thumbnailImage!)
                            ResultHolder.GetInstance().SetImage(index: 0, cgImage: rawImage.cgImage!)
                        }catch{
                            print("Thumbnail image is still processing")
                        }
                        //撮影画面を消す
                        self.parent.show.toggle()
                    }
                    
                        
                  



                    
                    
                }
            }

    
        }
        
        func saveMovieToPhotoLibrary(fileURL: URL) {
            //カメラロールに保存
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileURL)
            })
// アラーム"Cannot be called with asCopy = NO on non-main thread."が出るので削除
//            { saved, error in
//                let success = saved && (error == nil)
//                let title = success ? "Success" : "Error"
//                let message = success ? "Video saved." : "Failed to save video."
//
//                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
//            }
        }
        
        //サムネイル切り出し　https://qiita.com/doge_kun55/items/727b5caf100a40739bdf
        func thumnailImageForFileUrl(fileUrl: URL) -> UIImage? {
                let asset = AVAsset(url: fileUrl)

                let imageGenerator = AVAssetImageGenerator(asset: asset)

                do {
                    let thumnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1,timescale: 60), actualTime: nil)
                    //print("サムネイルの切り取り成功！")
                    return UIImage(cgImage: thumnailCGImage, scale: 0, orientation: .right)
                }catch let err{
                    print("エラー\(err)")
                }
                return nil
            }
        
        
        
        func saveToResultHolder(fileURL: URL){
            //ResultHolderに保存
            ResultHolder.GetInstance().SetMovieUrls(Url: fileURL.absoluteString)
        }
    }
}


class CircleView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            context.setLineWidth(3.0)
            UIColor.red.set()

            let center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
            let radius = (frame.size.width - 10) / 2

            context.addArc(center: center, radius: radius, startAngle: 0.0, endAngle: .pi * 2.0, clockwise: true)
            context.strokePath()
        }
    }
}


class RectangleView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            context.setLineWidth(3.0)
            UIColor.red.set()

            let width = frame.size.width
            let height = frame.size.width

            context.addRect(CGRect(origin:CGPoint(x:0, y:width/8), size: CGSize(width:width, height:height)))
            context.strokePath()
        }
    }
}
