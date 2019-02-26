//
//  CALayer.swift
//  Telega
//
//  Created by Roman Kyslyy on 2/26/19.
//  Copyright © 2019 Roman Kyslyy. All rights reserved.
//

import UIKit

extension CALayer {
	func pause() {
		let pausedTime: CFTimeInterval = self.convertTime(
			CACurrentMediaTime(),
			from: nil)
		self.speed = 0.0
		self.timeOffset = pausedTime
	}

	func resume() {
		let pausedTime: CFTimeInterval = self.timeOffset
		self.speed = 1.0
		self.timeOffset = 0.0
		self.beginTime = 0.0
		let timeSincePause: CFTimeInterval = self.convertTime(
			CACurrentMediaTime(),
			from: nil) - pausedTime
		self.beginTime = timeSincePause
	}
}

