import Cocoa
import GPUImage

let sourceImage = NSImage(named: "ChairTest.png")

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
