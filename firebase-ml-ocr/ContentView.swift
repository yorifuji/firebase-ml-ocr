//
//  ContentView.swift
//  firebase-ml-ocr
//
//  Created by yorifuji on 2020/12/19.
//

import SwiftUI
import Firebase
//import Vision

struct ContentView: View {
    @State var image = UIImage(systemName: "camera.fill")!
    @State var showImagePicker = false
    @State var inputImage: UIImage?
    enum SheetType {
        case picker
        case camera
    }
    @State var sheetType: SheetType = .picker
    @State var showActionSheet = false

    @State var recognizedText = ""

    var sheet: ActionSheet {
        ActionSheet(
            title: Text("撮影"),
            buttons: [
                .default(Text("カメラで撮影")) {
                    inputImage = nil
                    sheetType = .camera
                    showImagePicker = true
                },
                .default(Text("アルバムから選択")) {
                    inputImage = nil
                    sheetType = .picker
                    showImagePicker = true
                },
                .cancel()
            ]
        )
    }


    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .onTapGesture {
                    self.showActionSheet = true
                }
                .actionSheet(isPresented: $showActionSheet, content: { sheet })
                .sheet(isPresented: $showImagePicker, onDismiss: {
                    guard let inputImage = self.inputImage else { return }
                    self.image = inputImage
                    recognize(image: image) { (result, text) in
                        guard result else { return }
                        if let text = text {
                            print(text)
                            self.recognizedText = text
                        }
                    }
                }) {
                    if self.sheetType == .picker {
                        ImagePicker(image: $inputImage, sourceType: .photoLibrary)
                    }
                    else {
                        ImagePicker(image: $inputImage, sourceType: .camera)
                    }
                }
            ScrollView(.vertical, showsIndicators: true) {
                Text(recognizedText)
                    .lineLimit(nil)
            }
        }
    }

    func recognize(image: UIImage, completion: ((Bool, String?) -> Void)? = nil) {
        guard image.cgImage != nil else {
            return
        }

        let vision = Vision.vision()
        let options = VisionCloudTextRecognizerOptions()
        options.languageHints = ["ja", "en"]
        let textRecognizer = vision.cloudTextRecognizer(options: options)

        let visionImage = VisionImage(image: image)
        textRecognizer.process(visionImage) { result, error in
            guard error == nil, let result = result else {
                if error != nil {
                    print(error?.localizedDescription ?? "textRecognizer error")
                }
                if let completion = completion {
                    completion(false, nil)
                }
                return
            }

            print(result.text)
            if let completion = completion {
                completion(true, result.text)
            }
//            for block in result.blocks {
//                print(block.text)
//                for line in block.lines {
//                    print(line.text)
//                    for element in line.elements {
//                        print(element.text)
//                    }
//                }
//            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?
    var sourceType: UIImagePickerController.SourceType

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {

    }
}

