import SwiftUI
import AudioToolbox
import Foundation
import CoreMotion
import AVFoundation
import MediaPlayer

let limitSteps = 10
let calendar = Calendar.current
private let soundID = SystemSoundID(kSystemSoundID_Vibrate)
private var counter = 1000

let musicData = NSDataAsset(name: "BrainPlaybackMusic")!.data
var musicPlayer:AVAudioPlayer!

struct ContentView: View {
    @State private var isShowSetTimeView = false
    @State private var isShowAlert = false
    @State private var isTimerMoving = false
    @State private var myTimer = Date()
    @State private var steps = 0
    
    private let pedometer = CMPedometer()
    private let brightness: CGFloat = UIScreen.main.brightness
    private let soundLevel = AVAudioSession.sharedInstance().outputVolume
    
    var body: some View {
        NavigationStack {
            VStack{
                let hour = calendar.component(.hour, from: myTimer)
                let minute = calendar.component(.minute, from: myTimer)
                if !isShowAlert{
                    Button(action: {
                        isShowSetTimeView = true
                        isTimerMoving = false
                        UIScreen.main.brightness = UIScreen.main.brightness + 0.01
                    },label:  {
                        Text("\(String(format: "%02d",hour)):\(String(format: "%02d",minute))")
                            .font(.system(size: 90))
                            .bold()
                    })
                    .sheet(isPresented: $isShowSetTimeView) {
                        SetTimeView(myTimer: $myTimer)
                    }
                    Text("にアラームを鳴らす")
                        .font(.title)
                        .foregroundColor(.primary)
                    Toggle(isOn: $isTimerMoving){}
                        .labelsHidden()
                        .onChange(of: isTimerMoving, initial: false) {
                            if isTimerMoving == true {
                                startTimer(settingTime: myTimer)
                                UIScreen.main.brightness = 0.0
                            }
                        }
                        .fixedSize()
                        .scaleEffect(1.5)
                        .padding()
                }else {
                    VStack{
                        HStack{
                            Text("\(String(format: "%02d",hour)):\(String(format: "%02d",minute))")
                                .font(.title)
                                .bold()
                            Text("のアラーム")
                                .font(.title)
                            
                        }
                        .padding()
                        HStack{
                            Text("あと")
                                .font(.title)
                                .foregroundColor(.primary)
                            Text("\(limitSteps-steps < 0 ? 0 : limitSteps-steps)")
                                .font(.system(size: 50))
                                .bold()
                                .foregroundColor(.red)
                            Text("歩")
                                .font(.title)
                                .foregroundColor(.primary)
                        }
                        Button{
                            MPVolumeView.setVolume(soundLevel)
                            stopAlarm()
                        }label: {
                            Text("アラーム停止")
                                .font(.title)
                                .foregroundStyle(.white)
                        }
                        .padding()
                        .background(steps < limitSteps ? Color(UIColor.lightGray):.blue)
                        .disabled(steps < limitSteps)
                    }
                }
            }
            .preferredColorScheme(.dark)
        }
    }
    
    func startTimer(settingTime: Date){
        var now = Date()
        var target = settingTime
        
        if now > target{
            target = Calendar.current.date(byAdding: .day, value: 1, to: target)!
        }
        
        var interval = target.timeIntervalSince(now)
        
        
        _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if !isTimerMoving {
                timer.invalidate()
            }
            now = Date()
            if target > now{
                interval -= 1
                let hours = Int(interval) / 3600
                let minutes = Int(interval) % 3600 / 60
                let seconds = Int(interval) % 60
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let formattedTarget = dateFormatter.string(from: target)
                print("\(formattedTarget)まで残り時間: \(hours)時間 \(minutes)分 \(seconds)秒")
            }else{
                alarmStart()
                timer.invalidate()
            }
        }
        
    }
    
    func soundCallback() {
        counter -= 1
        if counter > 0 {
            AudioServicesPlaySystemSound(soundID)
        } else {
            stopAlarm()
        }
    }
    
    func alarmStart() {
        MPVolumeView.setVolume(1.0)
        UIScreen.main.brightness = brightness
        isShowAlert = true
        startCountSteps()
                AudioServicesAddSystemSoundCompletion(soundID, nil, nil, { (_, _) in
                    ContentView().soundCallback()
                }, nil)
                AudioServicesPlaySystemSound(soundID)
        do{
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback)
            musicPlayer = try AVAudioPlayer(data: musicData)
            musicPlayer.numberOfLoops = -1
            musicPlayer.play()
        }catch{
            print("音の再生に失敗しました。")
        }
    }
    
    func stopAlarm(){
        isShowAlert = false
        isTimerMoving = false
        counter = 1000
        stopCountSteps()
        musicPlayer.stop()
        AudioServicesRemoveSystemSoundCompletion(soundID)
    }
    
    func startCountSteps(){
        if CMPedometer.isStepCountingAvailable() {
            pedometer.startUpdates(from: Date(), withHandler: {(pedometerData, error) in
                if let e = error {
                    print(e.localizedDescription)
                    return
                }
                guard let data = pedometerData else {
                    return
                }
                steps = Int(truncating: data.numberOfSteps)
            })
        }
    }
    
    func stopCountSteps() {
        pedometer.stopUpdates()
        steps = 0
    }
    
}
#Preview {
    ContentView()
}
