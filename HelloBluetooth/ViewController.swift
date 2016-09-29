import UIKit

class ViewController: UIViewController {
    var StrokeMeter: StrokeMeterIO!

    @IBOutlet weak var ledToggleButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        StrokeMeter = StrokeMeterIO(serviceUUID: "19B10010-E8F2-537E-4F6C-D104768A1214", delegate: self)
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
        if value > 0 {
            view.backgroundColor = UIColor.yellow
        } else {
            view.backgroundColor = UIColor.black
        }
    }
}
