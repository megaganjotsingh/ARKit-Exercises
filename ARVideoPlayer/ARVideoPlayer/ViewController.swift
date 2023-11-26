//
//  ViewController.swift
//  ARVideoPlayer
//
//  Created by Gaganjot Singh on 17/07/19.
//  Copyright © 2019 Gaganjot Singh. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
        
        resetTracking()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func resetTracking(){
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else{
            return
        }
        
        let configure = ARWorldTrackingConfiguration()
        configure.detectionImages = referenceImages
        sceneView.session.run(configure, options: [.resetTracking, .removeExistingAnchors])
        
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else{return}
        handleFoundImage(imageAnchor: imageAnchor, node: node)
    }
    
    func handleFoundImage(imageAnchor: ARImageAnchor, node: SCNNode){
        let size = imageAnchor.referenceImage.physicalSize
        if let videoNode = video(size: size){
            node.addChildNode(videoNode)
        }
    }
    func video(size: CGSize) -> SCNNode?{
        var videoNode = SCNNode()
        guard let videoUrl = Bundle.main.url(forResource: "giphy", withExtension: "mp4") else {
            print("error")
            return videoNode
        }
        
        let PlayerItem = AVPlayerItem(url: videoUrl)
        let avplayer = AVPlayer(playerItem: PlayerItem)
        
        avplayer.play()
        
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: avplayer.currentItem, queue: nil
        ) { notification in
            avplayer.seek(to: .zero)
            avplayer.play()
            print("reset Video")
        }
        
        let avMaterial = SCNMaterial()
        avMaterial.diffuse.contents = avplayer
        
        let videoPlane = SCNPlane(width: size.width, height: size.height)
        videoPlane.materials = [avMaterial]
        
        videoNode = SCNNode(geometry: videoPlane)
        videoNode.scale = SCNVector3(x: 0.5, y: 0.5, z: 0.5)
        videoNode.position = SCNVector3(0, 0, 0)
        videoNode.eulerAngles.x = -.pi / 2
        return videoNode
    }
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
