import UIKit

extension UIViewController {
    func presentAlert(title: String, message: String, buttonTitle: String?) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: buttonTitle ?? "Ok", style: .cancel, handler: nil))
        present(alertController, animated: true)
    }
}
