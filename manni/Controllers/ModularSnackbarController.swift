import UIKit
import Material

class ModularSnackbarController: SnackbarController {
    open override func prepare() {
        super.prepare()
        delegate = self
    }
}

extension ModularSnackbarController: SnackbarControllerDelegate {
    func snackbarController(snackbarController: SnackbarController, willShow snackbar: Snackbar) {
        print("snackbarController will show")
    }
    
    func snackbarController(snackbarController: SnackbarController, willHide snackbar: Snackbar) {
        print("snackbarController will hide")
    }
    
    func snackbarController(snackbarController: SnackbarController, didShow snackbar: Snackbar) {
        print("snackbarController did show")
    }
    
    func snackbarController(snackbarController: SnackbarController, didHide snackbar: Snackbar) {
        print("snackbarController did hide")
    }
}
