//
//  ViewController.swift
//  SceneKit-Primitives
//
//  Created by Mark Meretzky on 1/12/19.
//  Copyright © 2019 New York University School of Professional Studies. All rights reserved.
//

import UIKit;
import SceneKit;
import ARKit;

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        // Set the view's delegate.
        sceneView.delegate = self;
        sceneView.autoenablesDefaultLighting = true;
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true;
        
        // Show the world origin.
        sceneView.debugOptions = [.showWorldOrigin];
        
        // Load campus.
        loadCampus();
    }
    
    func loadCampus() {
        // Create a new scene.
        guard let scene: SCNScene = SCNScene(named: "art.scnassets/campus.scn") else {
            fatalError("loadCampus could not open art.scnassets/campus.scn");
        }

        // Set the scene to the view.
        sceneView.scene = scene;
        
        loadMainBuilding();
        loadSidewalks();
        loadGrass();
        
        //Page 470: loops to make 22 trees.

        for x in stride(from: Float(-2), through: Float(2), by: Float(0.5)) {
            loadTree(x: x, z:  7/8);
            loadTree(x: x, z: -7/8);
        }
        
        for z in stride(from: Float(-0.375), through: Float(0.375), by: Float(0.5)) {
            loadTree(x:  2, z: z);
            loadTree(x: -2, z: z);
        }
    }
    
    func loadMainBuilding() {  //p. 462
        //"geometry means "shape".  Dimensions in meters (p. 460).
        let geometry: SCNBox = SCNBox(width: 3.0, height: 1.0, length: 1.0, chamferRadius: 0.0);
        
        if let firstMaterial: SCNMaterial = geometry.firstMaterial {
            firstMaterial.diffuse.contents = UIColor.brown;
        } else {
            fatalError("loadMainBuilding geometry.firstMaterial == nil");
        }

        //Create, configure, and attach the new node.
        let node: SCNNode = SCNNode();
        node.geometry = geometry;
        node.position = SCNVector3(0.0, 0.0, 0.0); //z was -1 on p. 462
        sceneView.scene.rootNode.addChildNode(node);
    }
    
    //isDoubleSided needed only for sidewalks and grass.
    
    func loadSidewalks() {   //p. 464
        let geometry: SCNPlane = SCNPlane(width: 3.5, height: 1.5);
        
        if let firstMaterial: SCNMaterial = geometry.firstMaterial {
            firstMaterial.diffuse.contents = UIColor.gray;
            firstMaterial.isDoubleSided = true;
        } else {
            fatalError("loadSidewalks geometry.firstMaterial == nil");
        }

        //Convert -90 degrees to radians.
        let degrees: Double = -90;
        var measurement: Measurement = Measurement(value: degrees, unit: UnitAngle.degrees);
        measurement.convert(to: .radians);
        let radians: Double = measurement.value;

        //Create, configure, and attach the new node.
        let node: SCNNode = SCNNode();
        node.geometry = geometry;
        node.position = SCNVector3(0.0, -0.5, 0.0);
        node.eulerAngles = SCNVector3(radians, 0.0, 0.0);
        sceneView.scene.rootNode.addChildNode(node);
    }
    
    func loadGrass() {   //pp. 465-466
        let geometry = SCNPlane(width: 4.5, height: 2.0);

        if let firstMaterial: SCNMaterial = geometry.firstMaterial {
            firstMaterial.diffuse.contents = UIColor.green;
            firstMaterial.isDoubleSided = true;
        } else {
            fatalError("loadGrass geometry.firstMaterial == nil");
        }

        //Convert -90 degrees to radians.
        let degrees: Double = -90;
        var measurement: Measurement = Measurement(value: degrees, unit: UnitAngle.degrees);
        measurement.convert(to: .radians);
        let radians: Double = measurement.value;
        
        //Create, configure, and attach the new node.
        let node: SCNNode = SCNNode();
        node.geometry = geometry;
        node.position = SCNVector3(0.0, -0.501, 0.0);
        node.eulerAngles.x = Float(radians);
        sceneView.scene.rootNode.addChildNode(node);
    }
    
    func loadTree(x: Float, z: Float) {   //pp. 468-469
        let trunkGeometry: SCNCylinder = SCNCylinder(radius: 0.05, height: 0.5);
        
        if let firstMaterial: SCNMaterial = trunkGeometry.firstMaterial {
            firstMaterial.diffuse.contents = UIColor.brown;
        } else {
            fatalError("loadTree trunkGeometry geometry.firstMaterial == nil");
        }

        //Create, configure, and attach the trunkNode.
        let trunkNode: SCNNode = SCNNode();
        trunkNode.geometry = trunkGeometry;
        trunkNode.position = SCNVector3(x, -0.25, z);
        sceneView.scene.rootNode.addChildNode(trunkNode);
    
        let crownGeometry: SCNSphere = SCNSphere(radius: 0.2);
        
        if let firstMaterial = crownGeometry.firstMaterial {
            firstMaterial.diffuse.contents = UIColor.green;
        } else {
            fatalError("loadTree crownGeometry geometry.firstMaterial == nil");
        }

        //Create, configure, and attach the crownNode.
        let crownNode: SCNNode = SCNNode();
        crownNode.geometry = crownGeometry;
        crownNode.position = SCNVector3(0.0, 0.25, 0.0);
        trunkNode.addChildNode(crownNode);
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration();

        // Run the view's session
        sceneView.session.run(configuration);
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause();
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
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
