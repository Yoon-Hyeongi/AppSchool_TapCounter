import Foundation

class TimerData: ObservableObject {

    @Published var number: Int = 0              // 카운팅숫자
    @Published var stateString: String = ""     // 현재 상태
    @Published var isOn: Bool = false           // 자동카운팅 on/off
    var timer: Timer = Timer()
    
    // 카운팅 증가
    @objc func timerStart() {
        number += 1
    }
    
    // 카운팅 감소 , 0이 되면 정지
    @objc func timerReverse() {
        
        if number > 0 {
            number -= 1
        } else {
            number = 0
            isOn = false
            stateString = "Stop automatic counting"
        }
    }
    
    // 1초마다 1씩 증가시키는 타이머
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerStart), userInfo: nil, repeats: true)
        isOn = true
        stateString = "Start automatic counting"
    }
    
    // 1초마다 1씩 감소시키는 타이머
    func reverseTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerReverse), userInfo: nil, repeats: true)
        isOn = true
        stateString = "Start automatic counting"
    }
    
    // 타이머 정지
    func stopTimer() {
        timer.invalidate()
        isOn = false
        stateString = "Stop automatic counting"
    }

}
