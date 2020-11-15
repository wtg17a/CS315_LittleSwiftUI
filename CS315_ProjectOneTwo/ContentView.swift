//
//  ContentView.swift
//  CS315_ProjectOneTwo
//
//  Created by William Gibbs on 11/15/20.
//

import SwiftUI
import Combine

enum SquareStatus {
    case empty
    case player1
    case player2
}

class Square: ObservableObject {
    let didChange = PassthroughSubject<Void, Never>()
    
    var status: SquareStatus {
        didSet {
            didChange.send(())
        }
    }
    
    init(status: SquareStatus) {
        self.status = status
    }
}

class ModelBoard {
    var squares = [Square]()

    init() {
        for _ in 0...8 {
            squares.append(Square(status: .empty))
        }
    }
    
    func resetGame() {
        for i in 0...8 {
            squares[i].status = .empty
        }
    }
    
    private func checkIndexes(_ indexes: [Int]) -> SquareStatus? {
        var player1Counter:Int = 0
        var player2Counter:Int = 0
        for anIndex in indexes {
            let aSquare = squares[anIndex]
            if aSquare.status == .player1 {
                player1Counter = player1Counter + 1
            } else if aSquare.status == .player2 {
                player2Counter = player2Counter + 1
            }
        }
        if player1Counter == 3 {
            return .player1
        } else if player2Counter == 3 {
            return .player2
        }
        return nil
    }
    
    private var checkWinner:SquareStatus {
        get {
            if let check = self.checkIndexes([0, 1, 2]) {
                return check
            } else  if let check = self.checkIndexes([3, 4, 5]) {
                return check
            }  else  if let check = self.checkIndexes([6, 7, 8]) {
                return check
            }  else  if let check = self.checkIndexes([0, 3, 6]) {
                return check
            }  else  if let check = self.checkIndexes([1, 4, 7]) {
                return check
            }  else  if let check = self.checkIndexes([2, 5, 8]) {
                return check
            }  else  if let check = self.checkIndexes([0, 4, 8]) {
                return check
            }  else  if let check = self.checkIndexes([2, 4, 6]) {
                return check
            }
            return .empty
        }
    }
    
    var gameOver: (SquareStatus, Bool) {
        get {
            if checkWinner != .empty {
                return (checkWinner, true)
            } else {
                for i in 0...8 {
                    if squares[i].status == .empty {
                        return (.empty, false)
                    }
                }
                return (.empty, true)
            }
        }
    }
    
    private func aiMove() {
        var anIndex = Int.random(in: 0 ... 8)
        while (makeMove(index: anIndex, player: .player2) == false && gameOver.1 == false) {
            anIndex = Int.random(in: 0 ... 8)
        }
    }
    
    func makeMove(index: Int, player:SquareStatus) -> Bool {
        if squares[index].status == .empty {
            squares[index].status = player
            if player == .player1 { aiMove() }
            return true
        }
        return false
    }
}

struct SquareView: View {
    var dataSource:Square
    var action: () -> Void
    var body: some View {
        Button(action: {
            self.action()
        }) {
            Text((dataSource.status != .empty) ?
                (dataSource.status == .player1) ? "X" : "O"
                : " ")
                .frame(minWidth: 60, minHeight: 60)
                .background(Color.gray)
                .padding(EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4))
        }
    }
}

struct ContentView: View {
    private var checker = ModelBoard()
    @State private var isGameOver = false
    
    func buttonAction(_ index: Int) {
        _ = self.checker.makeMove(index: index, player: .player1)
        self.isGameOver = self.checker.gameOver.1
    }
    
    var body: some View {
        VStack {
            HStack {
                SquareView(dataSource: checker.squares[0]) { self.buttonAction(0) }
                SquareView(dataSource: checker.squares[1]) { self.buttonAction(1) }
                SquareView(dataSource: checker.squares[2]) { self.buttonAction(2) }
            }
            HStack {
                SquareView(dataSource: checker.squares[3]) { self.buttonAction(3) }
                SquareView(dataSource: checker.squares[4]) { self.buttonAction(4) }
                SquareView(dataSource: checker.squares[5]) { self.buttonAction(5) }
            }
            HStack {
                SquareView(dataSource: checker.squares[6]) { self.buttonAction(6) }
                SquareView(dataSource: checker.squares[7]) { self.buttonAction(7) }
                SquareView(dataSource: checker.squares[8]) { self.buttonAction(8) }
            }
        }.alert(isPresented: $isGameOver) { () -> Alert in
            Alert(title: Text("Game Over"),
                  message: Text(self.checker.gameOver.0 != .empty ?
                    (self.checker.gameOver.0 == .player1) ? "You Win!" : "iPhone Wins!"
                    : "Tie"), dismissButton: Alert.Button.destructive(Text("Ok")){
                        self.checker.resetGame()
                    })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
