//
//  UIImage.swift
//  Telega
//
//  Created by Roman Kyslyy on 2/26/19.
//  Copyright © 2019 Roman Kyslyy. All rights reserved.
//

import UIKit

enum JPEGQuality: CGFloat {
  case lowest  = 0
  case low     = 0.25
  case medium  = 0.5
  case high    = 0.75
  case highest = 1
}

extension UIImage{

  func resizedImage(newSize: CGSize) -> UIImage {
    guard self.size != newSize else { return self }
    UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
    self.draw(in: CGRect(
      x: 0,
      y: 0,
      width: newSize.width,
      height: newSize.height))
    let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return newImage
  }

  func resizedImageWithinRect(rectSize: CGSize) -> UIImage {
    let widthFactor = size.width / rectSize.width
    let heightFactor = size.height / rectSize.height
    var resizeFactor = widthFactor
    if size.height > size.width {
      resizeFactor = heightFactor
    }
    let newSize = CGSize(
      width: size.width/resizeFactor,
      height: size.height/resizeFactor)
    let resized = resizedImage(newSize: newSize)
    return resized
  }
  
  func imageWithImage (scaledToWidth: CGFloat) -> UIImage {
    let oldWidth = self.size.width
    let scaleFactor = scaledToWidth / oldWidth
    let newHeight = self.size.height * scaleFactor
    let newWidth = oldWidth * scaleFactor
    UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
    self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage!
  }

  func crop( rect: CGRect) -> UIImage {
    var rect = rect
    rect.origin.x *= self.scale
    rect.origin.y *= self.scale
    rect.size.width *= self.scale
    rect.size.height *= self.scale

    let imageRef = self.cgImage!.cropping(to: rect)
    let image = UIImage(
      cgImage: imageRef!,
      scale: self.scale,
      orientation: self.imageOrientation)
    return image
  }

  func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
    return jpegData(compressionQuality: jpegQuality.rawValue)
  }
}

