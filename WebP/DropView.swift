import Cocoa

class DropView: NSView, NSDraggingDestination {
    
    var cwebp: Compress2Webp = Compress2Webp()
    var config: ApplicationConfig = ApplicationConfig()
    
    override init(frame: NSRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        config.setDefaultValues()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        let acceptDragTypes = [
            NSPasteboardTypePNG,
            NSColorPboardType,
            NSFilenamesPboardType
            //NSImage.imagePasteboardTypes()
        ]

        registerForDraggedTypes(acceptDragTypes)
        //println(self.registeredDraggedTypes)
    }
    
    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        
        let compressionLevel: [String] = ["-q", "\(config.getCompressionLevel())"]
        let isLossless: [String] = config.getIsLossless() ? ["-lossless"] : []
        let isNoAlpha: [String] = config.getIsNoAlpha() ? ["-noalpha"] : []
        
        // get dragged files' path
        let pboard = sender.draggingPasteboard()
        let filePaths = pboard.propertyListForType(NSFilenamesPboardType) as NSArray
        
        // load dropped files using NSFileManager
        let manager = NSFileManager.defaultManager()
        var error: NSError?

        for filePath in filePaths as [String] {
            let attributes = manager.attributesOfFileSystemForPath(filePath, error: &error)
            if error != nil {
                println(error)
            } else {

                let fileName = filePath.lastPathComponent
                let fileExtension = filePath.pathExtension

                let saveName: String = fileName.stringByReplacingOccurrencesOfString(
                    fileExtension, withString: "webp", options: .CaseInsensitiveSearch, range: nil)
                let saveFolder: String = filePath.stringByReplacingOccurrencesOfString(
                    fileName, withString: "", options: .CaseInsensitiveSearch, range: nil)

                var arguments: [String] = []
                arguments += compressionLevel
                arguments += isLossless
                arguments += isNoAlpha
                arguments += [filePath, "-o", saveName]
                
                cwebp.setCurrentDirectoryPath(saveFolder)
                cwebp.setArguments(arguments)
                
                println(arguments)
                let standardOutput = cwebp.execute()

                //println(standardOutput)
            }
        }
        
        return true
    }
    
    var onDraggingEnteredHandler: ((sender: NSDraggingInfo) -> Void)?
    
    var onDraggingEndedHandler: ((sender: NSDraggingInfo) -> Void)?
    
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation  {
        
        // delegate to view controller
        self.onDraggingEnteredHandler?(sender: sender)
        
        return NSDragOperation.Copy
    }

    override func draggingEnded(sender: NSDraggingInfo?) {
        
        // delegate to view controller
        self.onDraggingEndedHandler?(sender: sender!)
    }
}
