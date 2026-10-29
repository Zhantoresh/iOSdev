import Foundation


struct Track {
    let title: String
    let artist: String

    let fileName: String
    
    let coverImageName: String

 
    var resourceName: String {
        (fileName as NSString).deletingPathExtension
    }


    var fileExtension: String {
        (fileName as NSString).pathExtension
    }
}


enum TrackLibrary {
    static let tracks: [Track] = [
        Track(title: "Track 1", artist: "Artist 1", fileName: "track01.mp3", coverImageName: "track01Cover"),
        Track(title: "Track 2", artist: "Artist 2", fileName: "track02.mp3", coverImageName: "track02Cover"),
        Track(title: "Track 3", artist: "Artist 3", fileName: "track03.mp3", coverImageName: "track03Cover"),
        Track(title: "Track 4", artist: "Artist 4", fileName: "track04.mp3", coverImageName: "track04Cover"),
        Track(title: "Track 5", artist: "Artist 5", fileName: "track05.mp3", coverImageName: "track05Cover"),
        Track(title: "Track 6", artist: "Artist 6", fileName: "track06.mp3", coverImageName: "track06Cover"),
        Track(title: "Track 7", artist: "Artist 7", fileName: "track07.mp3", coverImageName: "track07Cover"),
        Track(title: "Track 8", artist: "Artist 8", fileName: "track08.mp3", coverImageName: "track08Cover"),
        Track(title: "Track 9", artist: "Artist 9", fileName: "track09.mp3", coverImageName: "track09Cover"),
        Track(title: "Track 10", artist: "Artist 10", fileName: "track10.mp3", coverImageName: "track10Cover")
    ]
}
