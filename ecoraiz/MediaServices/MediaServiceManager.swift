import SwiftUI
import UIKit
import PhotosUI

// MARK: - Shared Media Manager for Camera and Photo Picker
class MediaServicesManager: NSObject, ObservableObject {
    static let shared = MediaServicesManager()
    
    @Published var selectedImage: UIImage?
    @Published var selectedImages: [UIImage] = []
    
    private var singleImageCallback: ((UIImage?) -> Void)?
    private var multipleImagesCallback: (([UIImage]) -> Void)?
    
    // Use a singleton pattern to ensure we only have one instance managing camera/photo access
    private override init() {
        super.init()
    }
    
    // MARK: - Camera Methods
    
    func takeSinglePhoto(from viewController: UIViewController? = nil, completion: @escaping (UIImage?) -> Void) {
        self.singleImageCallback = completion
        presentCamera(from: viewController, allowsEditing: false)
    }
    
    func takePhotosForCollection(from viewController: UIViewController? = nil, completion: @escaping ([UIImage]) -> Void) {
        self.multipleImagesCallback = completion
        self.selectedImages = []
        presentCamera(from: viewController, allowsEditing: false)
    }
    
    private func presentCamera(from viewController: UIViewController? = nil, allowsEditing: Bool = false) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("Camera not available")
            return
        }
        
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = allowsEditing
        picker.delegate = self
        
        getTopViewController(viewController)?.present(picker, animated: true)
    }
    
    // MARK: - Photo Library Methods
    
    func selectSinglePhoto(from viewController: UIViewController? = nil, completion: @escaping (UIImage?) -> Void) {
        self.singleImageCallback = completion
        presentPhotoLibrary(from: viewController, selectionLimit: 1)
    }
    
    func selectMultiplePhotos(from viewController: UIViewController? = nil, completion: @escaping ([UIImage]) -> Void) {
        self.multipleImagesCallback = completion
        self.selectedImages = []
        presentPhotoLibrary(from: viewController, selectionLimit: 0) // 0 means no limit
    }
    
    private func presentPhotoLibrary(from viewController: UIViewController? = nil, selectionLimit: Int) {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = selectionLimit
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        
        getTopViewController(viewController)?.present(picker, animated: true)
    }
    
    // MARK: - Helper Methods
    
    private func getTopViewController(_ viewController: UIViewController? = nil) -> UIViewController? {
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        
        if let providedViewController = viewController {
            return providedViewController
        } else if let rootViewController = keyWindow?.rootViewController {
            var topController = rootViewController
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }
    
    // Reset state
    func reset() {
        selectedImage = nil
        selectedImages = []
        singleImageCallback = nil
        multipleImagesCallback = nil
    }
}

// MARK: - UIImagePickerController Delegate
extension MediaServicesManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                // If we're expecting a single image
                if let callback = self.singleImageCallback {
                    self.selectedImage = image
                    callback(image)
                }
                // If we're collecting multiple images
                else if let callback = self.multipleImagesCallback {
                    self.selectedImages.append(image)
                    callback(self.selectedImages)
                }
            }
        }
        
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Call callbacks with nil or empty results
        if let callback = singleImageCallback {
            callback(nil)
        } else if let callback = multipleImagesCallback {
            callback([])
        }
        
        picker.dismiss(animated: true)
    }
}

// MARK: - PHPickerViewController Delegate
extension MediaServicesManager: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        // If no items were selected
        if results.isEmpty {
            if let callback = singleImageCallback {
                callback(nil)
            } else if let callback = multipleImagesCallback {
                callback([])
            }
            return
        }
        
        // Single image selection mode
        if let callback = singleImageCallback, let itemProvider = results.first?.itemProvider,
           itemProvider.canLoadObject(ofClass: UIImage.self) {
            
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                DispatchQueue.main.async {
                    guard let image = image as? UIImage else {
                        callback(nil)
                        return
                    }
                    
                    self?.selectedImage = image
                    callback(image)
                }
            }
        }
        // Multiple images selection mode
        else if let callback = multipleImagesCallback {
            let dispatchGroup = DispatchGroup()
            var loadedImages: [UIImage] = []
            
            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    dispatchGroup.enter()
                    
                    result.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                        if let image = image as? UIImage {
                            loadedImages.append(image)
                        }
                        dispatchGroup.leave()
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main) { [weak self] in
                self?.selectedImages = loadedImages
                callback(loadedImages)
            }
        }
    }
}

// MARK: - SwiftUI Wrappers
extension View {
    // Convenience methods for SwiftUI views
    func takePhoto(isPresented: Binding<Bool>, onImageCaptured: @escaping (UIImage?) -> Void) -> some View {
        return self.onChange(of: isPresented.wrappedValue) { newValue in
            if newValue {
                isPresented.wrappedValue = false // Reset state immediately
                MediaServicesManager.shared.takeSinglePhoto { image in
                    onImageCaptured(image)
                }
            }
        }
    }
    
    func pickPhoto(isPresented: Binding<Bool>, onImagePicked: @escaping (UIImage?) -> Void) -> some View {
        return self.onChange(of: isPresented.wrappedValue) { newValue in
            if newValue {
                isPresented.wrappedValue = false // Reset state immediately
                MediaServicesManager.shared.selectSinglePhoto { image in
                    onImagePicked(image)
                }
            }
        }
    }
    
    func pickMultiplePhotos(isPresented: Binding<Bool>, onImagesPicked: @escaping ([UIImage]) -> Void) -> some View {
        return self.onChange(of: isPresented.wrappedValue) { newValue in
            if newValue {
                isPresented.wrappedValue = false // Reset state immediately
                MediaServicesManager.shared.selectMultiplePhotos { images in
                    onImagesPicked(images)
                }
            }
        }
    }
}
