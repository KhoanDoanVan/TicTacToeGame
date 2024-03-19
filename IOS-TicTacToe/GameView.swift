//
//  ContentView.swift
//  IOS-TicTacToe
//
//  Created by Đoàn Văn Khoan on 18/03/2024.
//

import SwiftUI

struct GameView: View {
    let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    @State private var moves : [Move?] = Array(repeating: nil, count: 9)
    @State private var isGameDisable = false
    @State private var alertItem : AlertItem?
    
    var body: some View {
        GeometryReader{ geometry in
            VStack{
                Spacer()
                LazyVGrid(columns: columns, spacing: 0){
                    ForEach(0..<9){ index in
                        ZStack{
                            Circle()
                                .foregroundColor(Color(.darkGray))
                                .opacity(0.5)
                                .frame(width: geometry.size.width/3 - 10,
                                       height: geometry.size.height/3 - 120
                                )
                            
                            Image(systemName: moves[index]?.indicator ?? "")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        .onTapGesture {
                            if isSquareOccupied(in: moves, forIndex: index){
                                return
                            }
                            
                            moves[index] = Move(player: .human , boardIndex: index)
                            
                            if checkWinConditions(for: .human, in: moves){
                                alertItem = AlertContext.humanWin
                                return
                            }
                            
                            if checkDraw(in: moves){
                                alertItem = AlertContext.draw
                                return
                            }
                            
                            isGameDisable = true
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1){ // asynchronously
                                let computerPosition = determineComputerMovePosition(in: moves)
                                moves[computerPosition] = Move(player: .computer , boardIndex: computerPosition)
                                isGameDisable = false
                                
                                if checkWinConditions(for: .computer, in: moves){
                                    alertItem = AlertContext.computerWin
                                    return
                                }
                                
                                if checkDraw(in: moves){
                                    alertItem = AlertContext.draw
                                    return
                                }
                            }
                        }
                    }
                }
                Spacer()
            }
            .alert(item: $alertItem){ alertItem in
                Alert(
                    title: alertItem.title,
                    message: alertItem.message,
                    dismissButton: .default(alertItem.buttonTilte, action: { resetGame() })
                )
            }
            .disabled(isGameDisable)
        }
    }
    
    func isSquareOccupied(in moves : [Move?], forIndex index : Int) -> Bool{
        return moves.contains(where: {
            $0?.boardIndex == index
        })
    }
    
    // If AI can win, then win
    // If AI can't win, then block
    // If AI can't block, then take middle square
    // If AI can't take middle square, take random available square
    func determineComputerMovePosition(in moves : [Move?]) -> Int {
        let winPatterns : Set<Set<Int>> = [
            [0,1,2],[3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]
        ]
        // If AI can win, then win
        let computerMoves = moves.compactMap{ $0 }.filter({ $0.player == .computer })
        let computerPositions = Set(computerMoves.map { $0.boardIndex })
        
        for pattern in winPatterns {
            let winPositions = pattern.subtracting(computerPositions)
            
            if winPositions.count == 1 {
                let isAvailable = !isSquareOccupied(in: moves, forIndex: winPositions.first!)
                if isAvailable {
                    return winPositions.first!
                }
            }
        }
        
        // If AI can't win, then block
        let humanMoves = moves.compactMap{ $0 }.filter({ $0.player == .human })
        let humanPositions = Set(humanMoves.map { $0.boardIndex })
        
        for pattern in winPatterns {
            let winPositions = pattern.subtracting(humanPositions)
            
            if winPositions.count == 1 {
                let isAvailable = !isSquareOccupied(in: moves, forIndex: winPositions.first!)
                if isAvailable {
                    return winPositions.first!
                }
            }
        }
        
        // If AI can't block, then take middle square
        let centerSquare = 4
        if !isSquareOccupied(in: moves, forIndex: centerSquare){
            return centerSquare
        }
        
        // If AI can't take middle square, take random available square
        var movePosition = Int.random(in: 0..<9)
        while isSquareOccupied(in: moves, forIndex: movePosition){
            movePosition = Int.random(in: 0..<9)
        }
        return movePosition
    }
    
    func checkWinConditions(for player : Player, in moves : [Move?]) -> Bool {
        let winPatterns : Set<Set<Int>> = [
            [0,1,2],[3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]
        ]
        
        let playerMoves = moves.compactMap { $0 }.filter{ $0.player == player } // $0 is represented for frist parameter
        let playerPositions = Set(playerMoves.map{ $0.boardIndex }) // Set() is collection has unique values
        
        //        playerMoves:: [IOS_TicTacToe.Move(player: IOS_TicTacToe.Player.human, boardIndex: 0)]
        //        playerPositions:: [0]
        //        playerMoves:: [IOS_TicTacToe.Move(player: IOS_TicTacToe.Player.computer, boardIndex: 2)]
        //        playerPositions:: [2]
        //
        //        playerMoves:: [IOS_TicTacToe.Move(player: IOS_TicTacToe.Player.human, boardIndex: 0), IOS_TicTacToe.Move(player: IOS_TicTacToe.Player.human, boardIndex: 4)]
        //        playerPositions:: [0, 4]
        //        playerMoves:: [IOS_TicTacToe.Move(player: IOS_TicTacToe.Player.computer, boardIndex: 2), IOS_TicTacToe.Move(player: IOS_TicTacToe.Player.computer, boardIndex: 6)]
        //        playerPositions:: [2, 6]
        
        for pattern in winPatterns where pattern.isSubset(of: playerPositions){
            return true
        }
        
        return false
    }
    
    func checkDraw(in moves : [Move?]) -> Bool {
        return moves.compactMap{ $0 }.count == 9
    }
    
    func resetGame(){
        moves = Array(repeating: nil, count: 9)
    }
}

enum Player {
    case human, computer
}

struct Move {
    let player : Player
    let boardIndex : Int
    
    var indicator : String {
        return player == .human ? "xmark" : "circle"
    }
}

#Preview {
    GameView()
}
