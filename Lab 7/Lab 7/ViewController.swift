import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var maxSpeedLabel: UILabel!
    @IBOutlet weak var averageSpeedLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var maxAccelerationLabel: UILabel!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var bottomBarView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var startLocation: CLLocation?
    var lastLocation: CLLocation?
    var maxSpeed: CLLocationSpeed = 0.0
    var totalDistance: CLLocationDistance = 0.0
    var startTime: Date?
    var totalElapsedTime: TimeInterval = 0.0
    var maxAcceleration: Double = 0.0
    var speedLimitKmh: Double = 115.0
    var tripActive = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure CLLocationManager
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        mapView.showsUserLocation = true
        
        // Initial UI setup
        topBarView.backgroundColor = .white
        bottomBarView.backgroundColor = .gray
    }
    
    @IBAction func startTrip(_ sender: UIButton) {
        locationManager.startUpdatingLocation()
        startTime = Date()
        startLocation = nil
        lastLocation = nil
        maxSpeed = 0.0
        totalDistance = 0.0
        totalElapsedTime = 0.0
        maxAcceleration = 0.0
        tripActive = true
        
        
        
    }
    
    @IBAction func stopTrip(_ sender: UIButton) {
        locationManager.stopUpdatingLocation()
        tripActive = false
        
        
        
        
        // Calculate and display results
        updateUI()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        
        if startLocation == nil {
            startLocation = newLocation
            lastLocation = newLocation
            startTime = Date()
            return
        }
        
        let timeInterval = newLocation.timestamp.timeIntervalSince(lastLocation!.timestamp)
        let distance = newLocation.distance(from: lastLocation!)
        let speed = newLocation.speed
        
        totalElapsedTime += timeInterval
        totalDistance += distance
        
        if speed > maxSpeed {
            maxSpeed = speed
            
        }
        
        let acceleration = abs(speed - (lastLocation?.speed ?? 0.0)) / timeInterval
        if acceleration > maxAcceleration {
            maxAcceleration = acceleration
        }
        
        lastLocation = newLocation
        
        // Update UI continuously during trip
        if tripActive {
            updateUI()
        }
    }
    
    func updateUI() {
        // Update UI elements with data from location updates
        speedLabel.text = "\(Int(lastLocation?.speed ?? 0.0 * 3.6)) km/h"
        maxSpeedLabel.text = "\(Int(maxSpeed * 3.6)) km/h"
        averageSpeedLabel.text = "\(Int(totalDistance / totalElapsedTime * 3.6)) km/h"
        distanceLabel.text = "\(String(format: "%.2f", totalDistance / 1000)) km"
        maxAccelerationLabel.text = "\(String(format: "%.2f", maxAcceleration)) m/s²"
        
        // Update top bar color based on speed limit
        if let currentSpeed = lastLocation?.speed, currentSpeed > speedLimitKmh / 3.6 {
            topBarView.backgroundColor = .red
        } else {
            topBarView.backgroundColor = .white
        }
        
        // Update bottom bar color based on trip status
        if tripActive {
            bottomBarView.backgroundColor = .green
        } else {
            bottomBarView.backgroundColor = .gray
        }
        
        // Zoom map to user's location
        if let userLocation = lastLocation {
            let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        }
    }
}

