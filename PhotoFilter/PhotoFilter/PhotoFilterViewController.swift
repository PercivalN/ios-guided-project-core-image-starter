import UIKit
import CoreImage
import Photos

class PhotoFilterViewController: UIViewController {


	var originalImage: UIImage? {
		didSet {

		}
	}

	private var filter = CIFilter(name: "CIColorControls")!
	private var context = CIContext(options: nil)

	@IBOutlet var brightnessSlider: UISlider!
	@IBOutlet var contrastSlider: UISlider!
	@IBOutlet var saturationSlider: UISlider!
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
		filter.setValue(brightnessSlider.value, forKey: kCIInputBrightnessKey)
		filter.setValue(contrastSlider.value, forKey: kCIInputContrastKey)
		filter.setValue(saturationSlider.value, forKey: kCIInputSaturationKey)

		guard let outputCIImage = filter.outputImage else { return image }

		guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: CGPoint.zero, size: image.size)) else { return image }

		return UIImage(cgImage: outputCGImage)
	}
	
	// MARK: Actions
	
	@IBAction func choosePhotoButtonPressed(_ sender: Any) {
		// TODO: show the photo picker so we can choose on-device photos
		// UIImagePickerController + Delegate
	}
	
	@IBAction func savePhotoButtonPressed(_ sender: UIButton) {

		// TODO: Save to photo library
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
		if let originalImage = originalImage {
			imageView.image = filterImage(originalImage)
		} else {
			imageView.image = nil
		}
	}
}

