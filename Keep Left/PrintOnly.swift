//  15 April 2024
/*
//    func makeVehicle() -> Vehicle {
    func makeVehicle() {
        var fName: String = ""
        let maxVehicles: Int = (maxCars+maxTrucks+maxBuses)
        
        var sKLAll: Vehicle = Vehicle(imageName: vehImage + "C1")       //Dummy node for 'All Vehicles' KL
        sKLAll.name = "sKLVehicle_0"
        sKLAll.distance = 0.0
        sKLAllVehicles.append(sKLAll)       //Place sKAll into position 0 of array
        var f8KLAll: F8Vehicle = F8Vehicle(imageName: vehImage + "C1")       //Dummy node for 'All Vehicles' KL
        f8KLAll.name = "sKLVehicle_0"
        f8KLAll.distance = 0.0
        f8KLAllVehicles.append(f8KLAll)

        var sOtherAll: Vehicle = Vehicle(imageName: vehImage + "C1")    //Dummy node for 'All Vehicles' Other
        sOtherAll.name = "sOtherVehicle_0"
        sOtherAll.distance = 0.0
        sOtherAllVehicles.append(sOtherAll) //Place sOtherAll into position 0 of array
        var f8OtherAll: F8Vehicle = F8Vehicle(imageName: vehImage + "C1")    //Dummy node for 'All Vehicles' Other
        f8OtherAll.name = "f8OtherVehicle_0"
        f8OtherAll.distance = 0.0
        f8OtherAllVehicles.append(f8OtherAll)

        for i in 1...numVehicles {
            var randomVehicle = Int.random(in: 1...maxVehicles)
            var vWidth: CGFloat = 2.8   //Car width. Set truck & bus width = 2.5m (allow 300mm for side mirrors?) SET ALL = 2.5M FOR NOW!!!
            
            if NumberedVehicles == false {  //false = normal else display numbers instead of vehicles!
                switch randomVehicle {
                case 1...maxCars:                       //Vehicle = Car
                fName = "C\(randomVehicle)"
                case (maxCars+1)...(maxCars+maxTrucks): //Vehicle = Truck
                fName = "T\(randomVehicle-maxCars)"
                    vWidth = 2.8
                default:                                //Vehicle = Bus
                fName = "B\(randomVehicle-maxCars-maxTrucks)"
                    vWidth = 2.8
                }
                
            } else {    //NumberedVehicles != 0 therefore display no's for vehicles!
                switch randomVehicle {
                case 1...maxCars:                       //Vehicle = Car
                    //                fName = "C\(randomVehicle)"
                    fName = "No\(i)"
                case (maxCars+1)...(maxCars+maxTrucks): //Vehicle = Truck
                    //                fName = "T\(randomVehicle-maxCars)"
                    fName = "No\(i)"
                    vWidth = 2.8
                default:                                //Vehicle = Bus
                    //                fName = "B\(randomVehicle-maxCars-maxTrucks)"
                    fName = "No\(i)"
                    vWidth = 2.8
                }
            }       //end NumberedVehicles
            
            var sKLVehicle: Vehicle = Vehicle(imageName: vehImage + String(fName))
            
            setAspectForWidth(sprite: sKLVehicle, width: vWidth)  //Sets veh width = 2m (default) & maintains aspect ratio
             let vehSize = sKLVehicle.size
            
            sKLVehicle.zPosition = +50
            sKLVehicle.name = "stKL_\(i)"   //sKLVehicle_x -> Straight Track 1, f1Vehicle_x -> Figure 8 Track 1, g1Vehicle_x -> Game Track 1.
            sKLVehicle.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: sKLVehicle.size.width, height: (sKLVehicle.size.height + gapBetween)))   //Make rectangle same size as sprite + 0.75m front and back!
            sKLVehicle.physicsBody?.friction = 0
            sKLVehicle.physicsBody?.restitution = 0
            sKLVehicle.physicsBody?.linearDamping = 0
            sKLVehicle.physicsBody?.angularDamping = 0
            sKLVehicle.physicsBody?.allowsRotation = false
            sKLVehicle.physicsBody?.isDynamic = true
            
            sBackground.addChild(sKLVehicle)
            
            //_________________________ Fig 8 Track below __________________________________________________
            var f8KLVehicle: F8Vehicle = F8Vehicle(imageName: vehImage + String(fName))

            f8KLVehicle.size = vehSize

            f8KLVehicle.zPosition = 10      //Set starting "altitude" above track and below bridge
            f8KLVehicle.name = "f8KL_\(i)"  //sKLVehicle_x -> Straight Track 1, f1Vehicle_x -> Figure 8 Track 1, g1Vehicle_x -> Game Track 1.
            f8KLVehicle.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: f8KLVehicle.size.width, height: (f8KLVehicle.size.height + gapBetween)))   //Make rectangle same size as sprite + 0.5m front and back!
            f8KLVehicle.physicsBody?.friction = 0
            f8KLVehicle.physicsBody?.restitution = 0
            f8KLVehicle.physicsBody?.linearDamping = 0
            f8KLVehicle.physicsBody?.angularDamping = 0
            f8KLVehicle.physicsBody?.allowsRotation = false
            f8KLVehicle.physicsBody?.isDynamic = false

            f8Background.addChild(f8KLVehicle)
            //_________________________ Fig 8 Track above __________________________________________________

            var sOtherVehicle: Vehicle = Vehicle(imageName: vehImage + String(fName))
            setAspectForWidth(sprite: sOtherVehicle, width: vWidth)  //Sets veh width = 2m (default) & maintains aspect ratio
            let secSize = sOtherVehicle.size
            
            sOtherVehicle.otherTrack = true //Flag identifies vehicle as being on the otherTrack!
            sOtherVehicle.zPosition = +50
            sOtherVehicle.name = "stOt_\(i)"  //sOtherVehicle_x -> Straight Track 2, f2Vehicle_x -> Figure 8 Track 2, g2Vehicle_x -> Game Track 2.
            sOtherVehicle.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: secSize.width, height: secSize.height + 1))   //Make rectangle same size as sprite + 0.5m front and back!
            sOtherVehicle.physicsBody?.friction = 0
            sOtherVehicle.zRotation = CGFloat(Double.pi)  //rotate 180 degrees //XXXXXXXXXX
            sOtherVehicle.physicsBody?.restitution = 0
            sOtherVehicle.physicsBody?.linearDamping = 0
            sOtherVehicle.physicsBody?.angularDamping = 0
            sOtherVehicle.physicsBody?.allowsRotation = false
            sOtherVehicle.physicsBody?.isDynamic = true
            
            sBackground.addChild(sOtherVehicle)

            //_________________________ Fig 8 Track below __________________________________________________
            var f8OtherVehicle: F8Vehicle = F8Vehicle(imageName: vehImage + String(fName))

            f8OtherVehicle.size = secSize

            f8OtherVehicle.otherTrack = true     //Flag identifies vehicle as being on the otherTrack!
            f8OtherVehicle.zPosition = 10       //Set starting "altitude" above track and below bridge
            f8OtherVehicle.name = "f8Ot_\(i)"  //sKLVehicle_x -> Straight Track 1, f1Vehicle_x -> Figure 8 Track 1, g1Vehicle_x -> Game Track 1.
            f8OtherVehicle.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: f8OtherVehicle.size.width, height: f8OtherVehicle.size.height + 1))   //Make rectangle same size as sprite + 0.5m front and back!
            f8OtherVehicle.physicsBody?.friction = 0
            f8OtherVehicle.physicsBody?.restitution = 0
            f8OtherVehicle.physicsBody?.linearDamping = 0
            f8OtherVehicle.physicsBody?.angularDamping = 0
            f8OtherVehicle.physicsBody?.allowsRotation = false
            f8OtherVehicle.physicsBody?.isDynamic = false

            f8Background.addChild(f8OtherVehicle)
            //_________________________ Fig 8 Track above __________________________________________________

            f8KLAllVehicles.append(f8KLVehicle)
            f8OtherAllVehicles.append(f8OtherVehicle)

            sKLVehicle = placeVehicle(sKLVehicle: sKLVehicle, sOtherVehicle: sOtherVehicle)

            t1Stats["Name"]?.append(sKLVehicle.name!)
            t1Stats["Actual Speed"]?.append(0.0)
            if let unwrapped = t1Stats["Name"]?[i] {
            }
        }
        
        gameStage = gameStage & 0x3F    //Clear 2 MSBs when vehicles all exist (Int = 8 bits)
                                        //  - allows processing of vehicle speeds etc.
        return
//        return sKLVehicle
    }
*/
