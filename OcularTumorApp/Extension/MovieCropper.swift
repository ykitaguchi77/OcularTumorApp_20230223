//
//  MovieCropper.swift
//  OcularTumorApp
//
//  Created by Yoshiyuki Kitaguchi on 2021/12/23.
//

import Foundation
import UIKit
import AVKit

final class MovieCropper {
    
    static func exportSquareMovie(sourceURL: URL, destinationURL: URL, fileType: AVFileType, completion: (() -> Void)?) {
        
        let avAsset: AVAsset = AVAsset(url: sourceURL)
        
        let videoTrack: AVAssetTrack = avAsset.tracks(withMediaType: AVMediaType.video)[0]
        let audioTracks: [AVAssetTrack] = avAsset.tracks(withMediaType: AVMediaType.audio)
        let audioTrack: AVAssetTrack? =  audioTracks.count > 0 ? audioTracks[0] : nil
        
        let mixComposition : AVMutableComposition = AVMutableComposition()
        
        let compositionVideoTrack: AVMutableCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)!
        let compositionAudioTrack: AVMutableCompositionTrack? = audioTrack != nil
            ? mixComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
            : nil
        
        try! compositionVideoTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: avAsset.duration), of: videoTrack, at: CMTime.zero)
        try! compositionAudioTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: avAsset.duration), of: audioTrack!, at: CMTime.zero)
        
        compositionVideoTrack.preferredTransform = videoTrack.preferredTransform
        
        var croppedVideoComposition: AVMutableVideoComposition? = nil

        let squareEdgeLength: CGFloat = videoTrack.naturalSize.height
        let croppingRect: CGRect = CGRect(x: (videoTrack.naturalSize.width - squareEdgeLength) / 2, y: 0, width: squareEdgeLength, height: squareEdgeLength)
        let transform: CGAffineTransform = videoTrack.preferredTransform.translatedBy(x: -croppingRect.minX, y: -croppingRect.minY)
        
        // layer instruction を正方形に
        let layerInstruction: AVMutableVideoCompositionLayerInstruction = AVMutableVideoCompositionLayerInstruction.init(assetTrack: compositionVideoTrack)
        layerInstruction.setCropRectangle(croppingRect, at: CMTime.zero)
        layerInstruction.setTransform(transform, at: CMTime.zero)
        
        // instruction に、先程の layer instruction を設定する
        let instruction: AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: avAsset.duration)
        instruction.layerInstructions = [layerInstruction]
        
        // video composition に、先程の instruction を設定する。また、レンダリングの動画サイズを正方形に設定する
        croppedVideoComposition = AVMutableVideoComposition()
        croppedVideoComposition?.instructions = [instruction]
        croppedVideoComposition?.frameDuration = CMTimeMake(value: 1, timescale: 30)
        croppedVideoComposition?.renderSize = CGSize(width: squareEdgeLength, height: squareEdgeLength)
    
        // エクスポートの設定。先程の video compsition をエクスポートに使うよう設定する。
        let assetExport = AVAssetExportSession.init(asset: mixComposition, presetName: AVAssetExportPresetMediumQuality)
        assetExport?.outputFileType = fileType
        assetExport?.outputURL = destinationURL
        if let videoComposition = croppedVideoComposition {
            assetExport?.videoComposition = videoComposition
        }
        
        // エクスポート先URLに既にファイルが存在していれば、削除する (上書きはできないので)
        if FileManager.default.fileExists(atPath: (assetExport?.outputURL?.path)!) {
            try! FileManager.default.removeItem(atPath: (assetExport?.outputURL?.path)!)
        }
        
        // クロップした動画をエクスポート
        assetExport?.exportAsynchronously(completionHandler: {
            if let completionHandler = completion {
                completionHandler()
            }
        })
        
    }
    
}
