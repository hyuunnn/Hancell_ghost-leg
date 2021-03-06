Public Declare Function GetTickCount64 Lib "kernel32.dll" () As Long

' https://stackoverflow.com/questions/6960434/timing-delays-in-vba
Sub WaitFor(NumOfSeconds As Double)
  Dim SngSec as Double
  SngSec = Timer + NumOfSeconds
  Do While Timer < SngSec
    DoEvents
  Loop
End Sub

Sub moveLeg(ByRef name, ByRef i, ByRef legLength, ByRef CellIdx, ByRef startIdx)
  TimeNum = Range("E3:E3").Value
  
  Do While 1
    ' 오른쪽에 있는 경우 +1 처리
    if Cells(i, CellIdx * 2 + 1) = "-" Then
      Cells(i, CellIdx * 2).Select
      Call WaitFor(TimeNum)
      CellIdx = Cellidx + 1
      Cells(i, CellIdx * 2).Select
      Call WaitFor(TimeNum)
      i = i + 1
          
    ' 왼쪽에 있는 경우 -1 처리 (B라인부터 시작하므로 A라인에 대한 예외처리 필요하지 않음)
    ElseIf Cells(i, CellIdx * 2 - 1) = "-" Then
      Cells(i, CellIdx * 2).Select
      Call WaitFor(TimeNum)
      CellIdx = CellIdx - 1
      Cells(i, CellIdx * 2).Select
      Call WaitFor(TimeNum)
      i = i + 1
              
    Else
      Cells(i, CellIdx * 2).Select
      Call WaitFor(TimeNum)
      i = i + 1
    End if
    
    ' 사다리 끝에 오면 종료
    if i = startIdx + legLength + 1 Then
      Cells(i, CellIdx * 2).Value = name
      Exit Do
    End if
  Loop
End Sub

Sub checkWinner()
  ' 시작지점 (사다리타기가 시작되는 구간)
  startIdx = 10

  ' 전역변수 생성이 불가능하므로, 데이터를 엑셀에 저장한 후에 그 값을 가져와서 사용
  personLength = Range("D5:D5").Value
  legLength = Range("D6:D6").Value
  CellIdx = Range("J5:J5").Value

  If CellIdx > personLength Or CellIdx < 1 Then
    MsgBox("값이 잘못되었습니다.")
  Else
    ' 한셀에서는 ByRef만 사용 가능하여(ByRef는 참조타입) i를 사용할 때마다 초기화
    i = startidx
    name = Cells(i - 1, CellIdx * 2).Value
    Call moveLeg(name, i, legLength, CellIdx, startIdx)
  End If
End Sub

Sub checkWinnerAll()
  ' 시작지점 (사다리타기가 시작되는 구간)
  startIdx = 10

  ' 전역변수 생성이 불가능하므로, 데이터를 엑셀에 저장한 후에 그 값을 가져와서 사용
  personLength = Range("D5:D5").Value
  legLength = Range("D6:D6").Value

  For j = 1 To personLength
    ' 한셀에서는 ByRef만 사용 가능하여(ByRef는 참조타입) CellIdx, i를 사용할 때마다 초기화
    CellIdx = j
    i = startIdx
    name = Cells(i - 1, CellIdx * 2).Value
    Call moveLeg(name, i, legLength, CellIdx, startIdx)
  Next
End Sub

Sub initalize()
  ' 시작지점 (이름도 지정하기 위해서 시작 주소에 9를 사용)
  startIdx = 9
  personIdx = 1

  personLength_tmp = Range("D5:D5").Value
  legLength_tmp = Range("D6:D6").Value

  ' 새롭게 사다리를 생성하기 전에 이전에 저장된 사다리 삭제
  If IsNumeric(personLength_tmp) and IsNumeric(legLength_tmp) Then
    For i = 1 To personLength_tmp * 2 - 1
      ' 꽝, 당첨 부분과 이름이 입력되는 부분까지 삭제하기 위하여 +2 추가
      For j = 0 To legLength_tmp + 2
        With Cells(j + startIdx, i + 1)
          .Interior.Color = RGB(255,255,255)
          .Borders.LineStyle = xlContinuous
          .Borders.Color = RGB(190,190,190)
          .ClearContents
        End With
      Next
    Next
  End If

  personLength = InputBox("사다리 개수", "사다리타기", "10")
  legLength = InputBox("사다리 크기", "사다리타기", "20")

  ' 값이 존재하는 경우에만 동작
  if IsNumeric(personLength) and IsNumeric(legLength) Then
    Range("D5:D5").Value = personLength
    Range("D6:D6").Value = legLength

    ' 마지막 끝 열은 필요가 없기 때문에 -1 사용
    For i = 1 To personLength * 2 - 1
      If i mod 2 = 1 Then
        Cells(startIdx, i + 1).Value = personIdx
        personIdx = personIdx + 1
      End If
      
      For j = 1 To legLength
        ' 이쁘게 보이기 위하여 A열을 최대로 축소하였기 때문에 B부터 시작하여 1을 추가하였음
        If i mod 2 = 0 Then
          With Cells(startIdx + j, i + 1)
            .Interior.Color = RGB(255,204,204)
            .Value = "l"
          End With
        Else
          Cells(startIdx + j, i + 1).Value = "l"
        End If
      Next
    Next
  End If
End Sub

Sub legMakeAutomation()
  startIdx = 10

  personLength = Range("D5:D5").Value
  legLength = Range("D6:D6").Value
  legCount = WorksheetFunction.Ceiling(legLength / 2, 1)

  ' C열에 해당하는 사다리부터 수정을 해야하기 때문에 2부터 시작
  For i = 2 To personLength
    ' startIdx 값인 10에 legLength만큼 for loop를 돌면 당첨, 꽝에 해당하는 부분까지 돌기 때문에 -1 사용
    For j = 0 To legLength - 1
      Cells(startIdx + j, i * 2 - 1).Value = "l"
    Next
  Next
              
  For i = 2 To personLength
  ' 양 옆에 사다리가 없으면 만들고, 있으면 pass하는 방법 사용 '
    For j = 0 To legCount
      ' 자정으로부터 지난 초를 의미하는 Timer 값으로 seed 값 지정 (소수점 2번째 자리로 계속 바뀌는 값)
      ' 직접 바꾸지 않으면 seed 값이 고정되어 있어 똑같은 결과가 나오므로 주기적으로 변경
      Randomize GetTickCount64() + Timer

      ' Int( ( upperbound - lowerbound + 1 ) * Rnd + lowerbound )
      randomRnd = Int(((legLength + startIdx - 1) - startIdx + 1) * Rnd() + startIdx)

      ' 양 옆에 사다리가 존재하는지 유무 체크하고 없으면 생성
      If Cells(randomRnd, i * 2 - 3) <> "-" And Cells(randomRnd, i * 2 + 1) <> "-" Then
        Cells(randomRnd, i * 2 - 1).Value = "-"
      End If
    Next
  Next
End Sub

Sub setRandomWinner()
  ' 자정으로부터 지난 초를 의미하는 Timer 값으로 seed 값 지정 (소수점 2번째 자리로 계속 바뀌는 값)
  ' 직접 바꾸지 않으면 seed 값이 고정되어 있어 똑같은 결과가 나오므로 주기적으로 변경
  Randomize Timer

  personLength = Range("D5:D5").Value
  legLength = Range("D6:D6").Value
  startIdx = 10
  randomRnd = Int(personLength * Rnd() + 1)

  For i = 1 To personLength
    if i = randomRnd Then
      Cells(startIdx + legLength, i * 2).Value = "당첨"
    Else
      Cells(startIdx + legLength, i * 2).Value = "꽝"
    End If
  Next
End Sub

Sub setMoveTime()
  maxNum = 100
  Set scrollObj = ActiveSheet.ScrollBars("스크롤 막대 6")
  Range("E3:E3").Value = (maxNum - scrollObj.Value) / 100
End Sub