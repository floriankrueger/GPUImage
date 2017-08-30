import Cocoa
import GPUImage

// Helpers

func sideBySideImage(input: NSImage, output: NSImage) -> NSImage? {
    let image = NSImage(size: CGSize(width: input.size.width + output.size.width, height: input.size.height))
    image.lockFocus()
    input.draw(in: CGRect(x: 0.0, y: 0.0, width: input.size.width, height: input.size.height))
    output.draw(in: CGRect(x: input.size.width, y: 0.0, width: output.size.width, height: output.size.height))
    image.unlockFocus()
    return image
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
sideBySideImage(input: imgChair, output: edgeDetectionImage!)

// pixellate with tweaking parameters
// see https://github.com/floriankrueger/GPUImage#image-processing for image processing technique parameters
// see https://github.com/floriankrueger/GPUImage#visual-effects for visual effect parameters
let pixellateFilter = GPUImagePixellateFilter()
pixellateFilter.fractionalWidthOfAPixel = 0.02
let pixellatedImage = pixellateFilter.image(byFilteringImage: imgChair)
sideBySideImage(input: imgChair, output: pixellatedImage!)

// custom filter
let customFilter = GPUImageFilter(fragmentShaderFromFile: "CustomFilter")!
let customFilteredImage = customFilter.image(byFilteringImage: imgChair)
sideBySideImage(input: imgChair, output: customFilteredImage!)

// chaining filters
let chainImageSource = GPUImagePicture(image: imgChair)! // the input object
chainImageSource.addTarget(pixellateFilter) // feed the image to pixellation filter
pixellateFilter.addTarget(customFilter)     // feed the pixellation filter output to the custom filter
customFilter.useNextFrameForImageCapture()  // capture the next frame that is created (there is only one)
chainImageSource.processImage()             // run the filter chain
let chainFilteredImage = customFilter.imageFromCurrentFramebuffer() // the result
sideBySideImage(input: imgChair, output: chainFilteredImage!)

// multi-image

func filter(images: [NSImage], using filter: (NSImage) -> NSImage) -> [NSImage] {
    return images.map { filter($0) }
}

let images = [imgBeauty, imgBMX, imgBody, imgCuba, imgHotCold, imgKinck]
let filtered = filter(images: images) { image in
    let filter = GPUImageGrayscaleFilter()
    return filter.image(byFilteringImage: image)
}

sideBySideImage(input: images[0], output: filtered[0])
sideBySideImage(input: images[1], output: filtered[1])
sideBySideImage(input: images[2], output: filtered[2])
sideBySideImage(input: images[3], output: filtered[3])
sideBySideImage(input: images[4], output: filtered[4])
sideBySideImage(input: images[5], output: filtered[5])
