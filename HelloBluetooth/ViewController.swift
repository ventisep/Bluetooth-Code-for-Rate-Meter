import UIKit

class ViewController: UIViewController {
    var StrokeMeter: StrokeMeterIO!

    @IBOutlet weak var ledToggleButton: UIButton!
    @IBOutlet weak var accelerationLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        StrokeMeter = StrokeMeterIO(serviceUUID: "E95D0000-251D-470A-A062-FA1922DFA9A8", delegate: self)
    }

    @IBAction func ledToggleButtonDown(_ sender: UIButton) {
        StrokeMeter.writeValue(1)
        print("written 1")
    }

    @IBAction func ledToggleButtonUp(_ sender: UIButton) {
        StrokeMeter.writeValue(0)
        print("written 0")
    }

}

extension ViewController: StrokeMeterIODelegate {
    func didReceiveValue(_ StrokeMeterIO: StrokeMeterIO, value: Int8) {
        accelerationLabel.text = String(value)
    }
}
