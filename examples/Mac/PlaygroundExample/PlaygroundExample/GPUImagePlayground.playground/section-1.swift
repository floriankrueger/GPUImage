import Cocoa
import GPUImage

let sourceImage = #imageLiteral(resourceName: "ChairTest.png")
let imgBeauty = #imageLiteral(resourceName: "DTS_Beauty.jpg")
let imgBMX = #imageLiteral(resourceName: "DTS_BMX.jpg")
let imgBody = #imageLiteral(resourceName: "DTS_Body.jpg")
let imgCuba = #imageLiteral(resourceName: "DTS_Cuba.jpg")
let imgHotCold = #imageLiteral(resourceName: "DTS_HotCold.jpg")
let imgKinck = #imageLiteral(resourceName: "DTS_Kinckerbocker.jpg")

// a simple edge detection
let edgeDetectionFilter = GPUImageSobelEdgeDetectionFilter()
let edgeDetectionImage = edgeDetectionFilter.image(byFilteringImage: sourceImage)

// pixellate with tweaking parameters 
// see https://github.com/floriankrueger/GPUImage#image-processing for image processing technique parameters
// see https://github.com/floriankrueger/GPUImage#visual-effects for visual effect parameters
let pixellateFilter = GPUImagePixellateFilter()
pixellateFilter.fractionalWidthOfAPixel = 0.02
let pixellatedImage = pixellateFilter.image(byFilteringImage: sourceImage)

// custom filter
let customFilter = GPUImageFilter(fragmentShaderFromFile: "CustomFilter")!
let customFilteredImage = customFilter.image(byFilteringImage: sourceImage)

// chaining filters
let chainImageSource = GPUImagePicture(image: sourceImage)! // the input object
chainImageSource.addTarget(pixellateFilter) // feed the image to pixellation filter
pixellateFilter.addTarget(customFilter)     // feed the pixellation filter output to the custom filter
customFilter.useNextFrameForImageCapture()  // capture the next frame that is created (there is only one)
chainImageSource.processImage()             // run the filter chain
let chainFilteredImage = customFilter.imageFromCurrentFramebuffer() // the result

// multi-image

func filter(images: [NSImage], using filter: (NSImage) -> NSImage) -> [NSImage] {
    return images.map { filter($0) }
}

let images = [imgBeauty, imgBMX, imgBody, imgCuba, imgHotCold, imgKinck]
let filtered = filter(images: images) { image in
    let filter = GPUImageGrayscaleFilter()
    return filter.image(byFilteringImage: image)
}

filtered[0]
filtered[1]
filtered[2]
filtered[3]
filtered[4]
filtered[5]
