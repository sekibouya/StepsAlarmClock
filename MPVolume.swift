import Foundation

import MediaPlayer

extension MPVolumeView {
    static func setVolume(_ volume: Float) -> Void {
        let volumeView = MPVolumeView()
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            slider?.value = volume
        }
    }
}
