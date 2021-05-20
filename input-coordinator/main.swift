//
//  main.swift
//  SimulatorsManager
//
//  Created by Tomasz Bartkowski on 09/05/2021.
//

import Quartz

let runLoop = RunLoop.current
let manager = SimulatorsManager()
runLoop.run(until: .distantFuture)
