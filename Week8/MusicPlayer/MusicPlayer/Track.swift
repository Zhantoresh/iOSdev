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
        Track(title: "Annihilate", artist: "Metro Boomin, Swae Lee, Lil Wayne, Offset",
              fileName: "annihilate.m4a", coverImageName: "annihilateCover"),
        Track(title: "Center Mass", artist: "Twenty One Pilots",
              fileName: "centerMass.m4a", coverImageName: "centerMassCover"),
        Track(title: "The Emptiness Machine", artist: "Linkin Park",
              fileName: "emptinessMachine.m4a", coverImageName: "emptinessMachineCover"),
        Track(title: "Karma Police", artist: "Radiohead",
              fileName: "karmaPolice.m4a", coverImageName: "karmaPoliceCover"),
        Track(title: "KICK OUT", artist: "Travis Scott",
              fileName: "kickOut.m4a", coverImageName: "kickOutCover"),
        Track(title: "Lithonia", artist: "Childish Gambino",
              fileName: "lithonia.m4a", coverImageName: "lithoniaCover"),
        Track(title: "Mr. Solo Dolo III", artist: "Kid Cudi",
              fileName: "mrSoloDoloIII.m4a", coverImageName: "mrSoloDoloIIICover"),
        Track(title: "Reincarnated", artist: "Kendrick Lamar",
              fileName: "reincarnated.m4a", coverImageName: "reincarnatedCover"),
        Track(title: "Telekinesis", artist: "Travis Scott",
              fileName: "telekinesis.m4a", coverImageName: "telekinesisCover"),
        Track(title: "Timeless", artist: "The Weeknd, Playboi Carti",
              fileName: "timeless.m4a", coverImageName: "timelessCover")
    ]
}
