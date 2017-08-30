import Cocoa
import GPUImage
import PlaygroundSupport

// Helpers

func sideBySideImage(input: NSImage, output: NSImage?) -> NSImage? {
    let image = NSImage(size: CGSize(width: input.size.width + (output?.size.width ?? input.size.width), height: input.size.height))
    image.lockFocus()
    input.draw(in: CGRect(x: 0.0, y: 0.0, width: input.size.width, height: input.size.height))
    if let outputImage = output {
        outputImage.draw(in: CGRect(x: input.size.width, y: 0.0, width: outputImage.size.width, height: outputImage.size.height))
    }
    image.unlockFocus()
    return image
}

func save(image: NSImage, toURL url: URL) -> Bool {
    if
        let tiff = image.tiffRepresentation,
        let tiffData = NSBitmapImageRep(data: tiff),
        let png = tiffData.representation(using: .PNG, properties: [:])
    {
        do {
            try png.write(to: url, options: .atomicWrite)
            return true
        } catch {
            return false
        }
    }
    else { return false }
}

typealias Item = (image: NSImage, name: String)

func convertImagesFromSharedPlaygroundData(using function: (NSImage) -> NSImage?) {
    let inputURL = URL(fileURLWithPath: "input", relativeTo: playgroundSharedDataDirectory)
    let outputURL = URL(fileURLWithPath: "output", relativeTo: playgroundSharedDataDirectory)
    
    let fm = FileManager.default
    let contents = try! fm.contentsOfDirectory(at: inputURL, includingPropertiesForKeys: [.isRegularFileKey], options: [])
    let inputItems: [Item] = contents.flatMap { url in
        guard let image = NSImage(contentsOf: url) else { return nil }
        print("found image named \"\(url.lastPathComponent)\"")
        return (image: image, name: url.lastPathComponent)
    }
    
    let outputItems: [Item] = inputItems.flatMap { (image, name) in
        print("converting image \"\(name)\" … ", terminator: "")
        guard let filteredImage = function(image) else { print("failed 🙁"); return nil }
        print("OK 👍")
        return (image: filteredImage, name: name)
    }
    
    outputItems.forEach { (image, name) in
        let url = outputURL.appendingPathComponent(name)
        print("saving \(url.lastPathComponent) … ", terminator: "")
        if save(image: image, toURL: url) {
            print("saved")
        } else {
            print("failed")
        }
    }
}

func multiFilter(images: [NSImage], using function: (NSImage) -> NSImage?) -> [NSImage?] {
    return images.map { function($0) }
}

// Images

let imgChair = #imageLiteral(resourceName: "ChairTest.png")
let imgBeauty = #imageLiteral(resourceName: "DTS_Beauty.jpg")
let imgBMX = #imageLiteral(resourceName: "DTS_BMX.jpg")
let imgBody = #imageLiteral(resourceName: "DTS_Body.jpg")
let imgCuba = #imageLiteral(resourceName: "DTS_Cuba.jpg")
let imgHotCold = #imageLiteral(resourceName: "DTS_HotCold.jpg")
let imgKinck = #imageLiteral(resourceName: "DTS_Kinckerbocker.jpg")

// a simple edge detection
let edgeDetectionFilter = GPUImageSobelEdgeDetectionFilter()
let edgeDetectionImage = edgeDetectionFilter.image(byFilteringImage: imgChair)
sideBySideImage(input: imgChair, output: edgeDetectionImage)

// pixellate with tweaking parameters
// see https://github.com/floriankrueger/GPUImage#image-processing for image processing technique parameters
// see https://github.com/floriankrueger/GPUImage#visual-effects for visual effect parameters
let pixellateFilter = GPUImagePixellateFilter()
pixellateFilter.fractionalWidthOfAPixel = 0.02
let pixellatedImage = pixellateFilter.image(byFilteringImage: imgChair)
sideBySideImage(input: imgChair, output: pixellatedImage)

// custom filter
let customFilter = GPUImageFilter(fragmentShaderFromFile: "CustomFilter")!
let customFilteredImage = customFilter.image(byFilteringImage: imgChair)
sideBySideImage(input: imgChair, output: customFilteredImage)

// chaining filters
let chainImageSource = GPUImagePicture(image: imgChair)! // the input object
chainImageSource.addTarget(pixellateFilter) // feed the image to pixellation filter
pixellateFilter.addTarget(customFilter)     // feed the pixellation filter output to the custom filter
customFilter.useNextFrameForImageCapture()  // capture the next frame that is created (there is only one)
chainImageSource.processImage()             // run the filter chain
let chainFilteredImage = customFilter.imageFromCurrentFramebuffer() // the result
sideBySideImage(input: imgChair, output: chainFilteredImage)

// MULTI-IMAGE

// images
let images = [imgBeauty, imgBMX, imgBody, imgCuba, imgHotCold, imgKinck]

// the filter function
let filter: ((NSImage) -> NSImage?) = { image in
    let filter = GPUImageGrayscaleFilter()
    return filter.image(byFilteringImage: image)
}

// the result
let filtered = multiFilter(images: images, using: filter)

sideBySideImage(input: images[0], output: filtered[0])
sideBySideImage(input: images[1], output: filtered[1])
sideBySideImage(input: images[2], output: filtered[2])
sideBySideImage(input: images[3], output: filtered[3])
sideBySideImage(input: images[4], output: filtered[4])
sideBySideImage(input: images[5], output: filtered[5])

// FILE INPUT & OUTPUT

// 1. create the directory "~/Documents/Shared Playground Data/input"
// 2. create the directory "~/Documents/Shared Playground Data/output"
// 3. put some images in "input" (please don't put anything else in there 😉)
// 4. uncomment the following line of code (it uses the filter function from above)

//convertImagesFromSharedPlaygroundData(using: filter)

// 5. run the playground

print("done 🎉")
