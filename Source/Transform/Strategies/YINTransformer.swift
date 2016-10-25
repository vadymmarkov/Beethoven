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

struct YINTransformer: Transformer {

  func transform(buffer: AVAudioPCMBuffer) throws -> Buffer {
    let buffer = try SimpleTransformer().transform(buffer: buffer)
    let diffElements = YINUtil.differenceA(buffer: buffer.elements)

    return Buffer(elements: diffElements)
  }
}
