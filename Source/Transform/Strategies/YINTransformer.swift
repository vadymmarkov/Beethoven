//
//  YINTransformer.swift
//  Beethoven
//
//  Created by Guillaume Laurent on 10/10/16.
//  Adapted from https://code.soundsoftware.ac.uk/projects/pyin/repository
//  by Matthias Mauch, Centre for Digital Music, Queen Mary, University of London.
//

import Foundation
import AVFoundation

public struct YINTransformer : Transformer {

  public func transformBuffer(_ buffer: AVAudioPCMBuffer) -> Buffer {

    let pointer = buffer.floatChannelData
    let elements = Array.fromUnsafePointer((pointer?.pointee)!, count:Int(buffer.frameLength))

    let diffElements = YINUtil.differenceA(buffer: elements)

    return Buffer(elements: diffElements)
  }
}
