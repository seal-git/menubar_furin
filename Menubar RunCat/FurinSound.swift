//
//  FurinSound.swift
//  Menubar RunCat
//
//  Created by Takumi Nakai on 2022/08/06.
//  Copyright © 2022 Takuto Nakamura. All rights reserved.
//

import AVFoundation

// 風鈴の音を鳴らすクラス
class FurinSound {
    private var players: [Player] = []
    private let maxPlayerNumber: Int = 10
    
    // 風鈴の速度を入力として音を鳴らす予定
    func playSound(movingSpeed: Int){
        // 複数の音を重ねて鳴らすためにはそれぞれの音を別々のプレイヤーで鳴らす必要がある
        // 現実装では音を鳴らすたびにプレイヤーを生成する方針で書いている
        // 関数内でプレイヤーを生成するだけだと関数終了直後にプレイヤーが破棄されるため、リストに放り込んで保持している
        // （あるいは、あらかじめリストにプレイヤーを放り込んでおいて順繰りに鳴らす方針でもいいかもしれない）
        let player = Player()
        let soundName: String = decideSound(movingSpeed: movingSpeed)
        if soundName.isEmpty { return }
        player.playSound(name: soundName)
        players.append(player)
        // 生成したプレイヤーをいつまでもリストに保持するとメモリ使用量がやばくなるため、プレイヤーの最大保持数に制限を設けている
        // 後の実装では音の再生を終えたプレイヤーが自動で破棄されるように書き直したい
        players = players.suffix(maxPlayerNumber)
    }
    
    // 再生する音源名を決めるファイル
    // ちゃんとしたロジックは後で考える
    func decideSound(movingSpeed: Int) -> String {
        if movingSpeed==0 { return "チーン" }
        if movingSpeed==1 { return "チーン弱" }
        return String() // 空文字列
    }
}


// システムから音声を出力するクラス
fileprivate class Player {
    private var audioPlayer: AVAudioPlayer!
    func playSound(name: String) {
        guard let path = Bundle.main.path(forResource: name, ofType: "mp3") else {
            print("音源ファイルが見つかりません")
            return
        }
        do {
            // AVAudioPlayerのインスタンス化
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            // AVAudioPlayerのデリゲートをセット
            audioPlayer.delegate = self as? AVAudioPlayerDelegate
            // 音声の再生
            audioPlayer.play()
            print("play:" + name)
        } catch {
        }
    }
}
