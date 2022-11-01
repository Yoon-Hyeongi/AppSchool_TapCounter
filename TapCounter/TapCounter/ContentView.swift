//
//  ContentView.swift
//  TapCounter
//
//  Created by 윤현기 on 2022/11/01.
//

/**
 탭 카운터를 만들어봅시다
 예를 들면 이런 기능이 있으면 좋겠지요?
    묀쪽밀면숫자줄이기
    롱으로 누르면 자동 증가 카운터시작/멈춤
    다섯, 열 단위마다 민수가 읽어주기?
 기록한 숫자들의 목록을 보여주는 등의 완성된 앱이 되기 위한 추가적인 기능도 구현해봅시다
 */

import SwiftUI

struct ContentView: View {
    @State private var upAndDown: String = "arrow.up.arrow.down.square"     // 드래그 버튼 이미지
    @State private var upAndDownColor: Color = .gray                        // 드래그 버튼 색상
    
    // .updating()에 사용되는 변수는 @GestureState라는 프로퍼티래퍼를 사용
    @GestureState private var offset: CGSize = .zero                        // 너비,높이 0으로 초기화
    @State private var longPress: Bool = false                              // 길게 누른 상태 초기화
    @ObservedObject var timerData: TimerData                                // TimerData
    
    
    var body: some View {
        
        // 드래그 제스쳐
        let drag = DragGesture()
            // 제스처의 실행부터 종료까지 상태변경될 때 호출
            .onChanged { value in
                // 시작좌표 - 종료좌료
            let yValue = value.startLocation.y - value.predictedEndLocation.y

                // 위쪽으로 드래그할 시 카운트를 증가 시킴
            if yValue > 0 {
                timerData.number += 1
                upAndDown = "arrow.up.square"
                upAndDownColor = .red
                timerData.stateString = "Count +"
                
            } else {
                // 아래쪽으로 드래그하다가 0에 도달하면 0에서 멈추도록 함
                if timerData.number <= 0 {
                    timerData.number = 0
                    upAndDown = "x.square"
                    upAndDownColor = .gray
                    timerData.stateString = "Minimum reached"
                } else {
                    // 아래쪽으로 드래그할 시 카운트를 감소 시킴
                    timerData.number -= 1
                    upAndDown = "arrow.down.square"
                    upAndDownColor = .blue
                    timerData.stateString = "Count -"
                }
            }
        }
        // onChanged()와 유사하지만 여기서 사용된 offset은 제스처가 종료됨과 동시에 초기상태로 초기화됨
            .updating($offset) { dragValue, state, transaction in
                            // 드래그한 위치로 해당 버튼을 이동 시킴
                            state = dragValue.translation
                        }
        // 제스처가 종료됨과 동시에 초기에 셋팅된 버튼 상태로 복구
            .onEnded { _ in
                upAndDown = "arrow.up.arrow.down.square"
                upAndDownColor = .gray
            }
        
        // 길게 누르는 제스처(+ 버튼)
        let longPressStart = LongPressGesture()
            // 제스처가 종료될 때
            .onEnded { _ in
            // 타이머가 켜져있으면 끄고, 꺼져있으면 켠다
            timerData.isOn ? timerData.stopTimer() : timerData.startTimer()     // 자동 증가 카운팅
        }
        
        // 길게 누르는 제스처(- 버튼)
        let longPressReverse = LongPressGesture()
            .onEnded { _ in
            timerData.isOn ? timerData.stopTimer() : timerData.reverseTimer()   // 자동 감소 카운팅
        }
        
        // 누를시에 카운트 증가
        let tapPlus = TapGesture()
            .onEnded {
                timerData.number += 1
                timerData.stateString = "Count +"
            }
        
        // 누를시에 카운트 감소
        let tapMinus = TapGesture()
            .onEnded {
                if timerData.number > 0 {
                    timerData.number -= 1
                    timerData.stateString = "Count -"
                } else {
                    // 음수가 될경우 값을 0으로 고정
                    timerData.number = 0
                    timerData.stateString = "Minimum reached"
                }
            }
        
        // 누를시에 카운트 초기화
        let tapReset = TapGesture()
            .onEnded {
                timerData.number = 0
                timerData.stateString = "Count Reset"
            }
        
        return VStack {
            
            Spacer()
            
            // 현재 상태를 표시해줄 텍스트
            Text("\(timerData.stateString)")
                .font(.title2).bold()
                .padding()
                .frame(width: 296, height: 40)
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(15)
            
            // 현재 숫자를 표시해줄 텍스트
            HStack {
                Text("\(String(timerData.number))")
                    .font(.largeTitle).bold()
                    .padding()
                    .frame(width: 200, height: 90)
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                
                // 액션 - 위로 드래그하면 카운트 증가 / 아래로 드래그하면 카운트 감소
                Image(systemName: upAndDown)
                    .resizable()
                    .offset(offset)
                    .frame(width: 90, height: 90)
                    .foregroundColor(upAndDownColor)
                    .gesture(drag)
                
                /**
                    Q. updating을 사용해서 구현해본 결과 프리뷰에선 동작하지만 시뮬레이터에선
                    [Modifying state during view update, this will cause undefined behavior.]
                      위와 같은 에러가 발생한다.
                 
                    A. 프리뷰에서만 동작하는 이유는 확실하게 파악은 못하였지만 updating은 현재 offset값의
                        변화에 반응하여 동작하고 있는데 이외의 다른 @GestureState변수가 아닌 값들을
                        변경하려 하는 것이 제스처 종료 후 초기값으로 돌아가는 updating과 무언가 맞지 않아서 그런것 같다는 추측...
                 
                    .gesture(DragGesture()
                        .updating($offset) { dragValue, state, transaction in
                        state = dragValue.translation

                        // 위로 드래그하면 카운트 증가
                        if state.height < 0 {
                            upAndDown = "arrow.up.square"
                            upAndDownColor = .red
                            timerData.number += 1

                        // 아래로 드래그하면 카운트 감소
                        } else {
                            upAndDown = "arrow.down.square"
                            upAndDownColor = .blue
                            timerData.number -= 1
                        }
                    }
                         // 끝나면 다시 원위치하고 버튼도 처음상태로
                        .onEnded { _ in
                            upAndDown = "arrow.up.arrow.down.square"
                            upAndDownColor = .gray
                        }
                    )
                 */
                
            }

            Spacer()
            
            HStack {
                Spacer()
                // 숫자 증가 버튼
                Image(systemName: "plus.square")
                    .resizable()
                    .frame(width: 90, height: 90)
                    .foregroundColor(.red)
                    .gesture(tapPlus)
                    .gesture(longPressStart)        // 자동 증가 카운팅
                
                Spacer()
                
                // 숫자 감소 버튼
                Image(systemName: "minus.square")
                    .resizable()
                    .frame(width: 90, height: 90)
                    .foregroundColor(.blue)
                    .gesture(tapMinus)
                    .gesture(longPressReverse)      // 자동 감소 카운팅
                
                Spacer()
                
                // 초기화 버튼
                Image(systemName: "c.square")
                    .resizable()
                    .frame(width: 90, height: 90)
                    .foregroundColor(.gray)
                    .gesture(tapReset)
                
                Spacer()
            }
            Spacer()

        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(timerData: TimerData())
    }
}
