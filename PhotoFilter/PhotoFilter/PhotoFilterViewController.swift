import UIKit
import CoreImage
import Photos

//enum SelectedIndex: Int {
//	case colorControls
//	case vignette
//}

class PhotoFilterViewController: UIViewController {


	var originalImage: UIImage? {
		didSet {
			guard let originalImage = originalImage else { return }
			// Height and width
			var scaledSize = imageView.bounds.size
			// 1x, 2x, or 3x
			let scale = UIScreen.main.scale
			scaledSize = CGSize(width: scaledSize.width * scale, height: scaledSize.height * scale)
			print("size: \(scaledSize)")
			scaledImage = originalImage.imageByScaling(toSize: scaledSize)
		}
	}

	var scaledImage: UIImage? {
		didSet {
			updateImage()
		}
	}

	private var filter = CIFilter(name: "CIColorControls")!
	private var context = CIContext(options: nil)

	@IBOutlet var topSlider: UISlider!
	@IBOutlet var middleSlider: UISlider!
	@IBOutlet var bottomSlider: UISlider!
	@IBOutlet var imageView: UIImageView!
	
	override func viewDidLoad() {
		super.viewDidLoad()

		originalImage = imageView.image
	}

	// MARK: Helper Methods

	private func filterImage(_ image: UIImage) -> UIImage {
		guard let cgImage = image.cgImage else { return image }

		let ciImage = CIImage(cgImage: cgImage)

		// Setup the filter

		// k = constant
		filter.setValue(ciImage, forKey: kCIInputImageKey) // "inputImage"

		setFilter()

		guard let outputCIImage = filter.outputImage else { return image }

		guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: CGPoint.zero, size: image.size)) else { return image }

		return UIImage(cgImage: outputCGImage)
	}
	
	// MARK: Actions
	
	@IBAction func choosePhotoButtonPressed(_ sender: Any) {
		presentImagePickerController()
		// UIImagePickerController + Delegate
	}

	private func presentImagePickerController() {
		guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
			print("The photo library is not available")
			return
		}

		let imagePicker = UIImagePickerController()
		imagePicker.sourceType = .photoLibrary
		imagePicker.delegate = self

		present(imagePicker, animated: true, completion: nil)
	}

	private func setFilter() {
		switch filter.name {
		case "CIVignette": setVignette()
			
		default: setColorControls()
		}
	}


	private func setColorControls() {

		filter.setValue(topSlider.value, forKey: kCIInputBrightnessKey)
		filter.setValue(middleSlider.value, forKey: kCIInputContrastKey)
		filter.setValue(bottomSlider.value, forKey: kCIInputSaturationKey)
	}

	private func setVignette() {

		filter.setValue(topSlider.value, forKey: kCIInputIntensityKey)
		filter.setValue(middleSlider.value, forKey: kCIInputRadiusKey)
		bottomSlider.isHidden = true
	}

	@IBAction func SegmentedControlChange(_ sender: UISegmentedControl) {
		switch sender.selectedSegmentIndex {
		case 0: filter = CIFilter(name: "CIColorControls")!
			setColorControlSliderValues()
		case 1: filter = CIFilter(name: "CIVignette")!
			set
		case 2: return
		case 3: return
		default: return

		}
	}

	private func setColorControlSliderValues() {
		topSlider.isHidden = false
		middleSlider.isHidden = false
		bottomSlider.isHidden = false

		topSlider.value = 0
		topSlider.minimumValue = -1
		topSlider.maximumValue = 1

		middleSlider.value = 0
		middleSlider.minimumValue = 0.25
		middleSlider.maximumValue = 4

		bottomSlider.value = 0
		bottomSlider.minimumValue = 0.25
		bottomSlider.maximumValue = 4
	}

	private func setVignetteSliderValues() {

        topSlider.value = 0
        topSlider.minimumValue = -1
        topSlider.maximumValue = 1
        middleSlider.value =  1
        middleSlider.minimumValue = 0
        middleSlider.maximumValue = 2
    }


	@IBAction func savePhotoButtonPressed(_ sender: UIButton) {
		guard let originalImage = originalImage else { return }
		let processedImage = filterImage(originalImage.flattened)
		PHPhotoLibrary.requestAuthorization { (status) in
			guard status == .authorized else { return }
			// Let the library know we are going to make changes
			PHPhotoLibrary.shared().performChanges({
				// Make a new photo creation request
				PHAssetCreationRequest.creationRequestForAsset(from: processedImage)
			}, completionHandler: { (success, error) in
				if let error = error {
					NSLog("Error saving photo: \(error)")
					return
				}
				DispatchQueue.main.async {
					print("Saved image!")
				}
			})
		}
	}
	

	// MARK: Slider events
	
	@IBAction func brightnessChanged(_ sender: UISlider) {
		if let originalImage = originalImage {
		imageView.image = filterImage(originalImage)
	}
	}
	
	@IBAction func contrastChanged(_ sender: Any) {

	}
	
	@IBAction func saturationChanged(_ sender: Any) {

	}

	private func updateImage() {
		if let scaledImage = scaledImage {
			imageView.image = filterImage(scaledImage)
		} else {
			imageView.image = nil
		}
	}
}

extension PhotoFilterViewController: UIImagePickerControllerDelegate {
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

		// First use the editted (if it exists), otherwise use the original
		if let image = info[.editedImage] as? UIImage {
			originalImage = image
		} else if let image = info[.originalImage] as? UIImage {
			originalImage = image
		}
		picker.dismiss(animated: true, completion: nil)
	}

	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true, completion: nil)
	}
}

extension PhotoFilterViewController: UINavigationControllerDelegate {

}
