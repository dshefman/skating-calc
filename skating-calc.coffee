couples = []
judges = []
dances = []

$ ->
  $('h1').click ->
    $(this).hide 'slow'
  $('#coupleAdd').click ->
    addCouple()
  $('#coupleRemove').click ->
    removeCouple()
  $('#judgeAdd').click ->
    addJudge()
  $('#judgeRemove').click ->
    removeJudge()
  $('#danceAdd').click ->
    addDance()
  $('#danceRemove').click ->
    removeDance()
  $('#marksGen').click ->
    generateMarks()

addCouple = ->
  newDivContent = '<div><input type="text" class="numberInput">'
  newDivContent += '<input type="text" class="nameInput">'
  newDivContent += '<br /></div>'
  $('#coupleFields').append newDivContent

  couples.push {number: "", name: ""}

  thisIndex = couples.length - 1
  $('#coupleFields .numberInput').last().focusout ->
    couples[thisIndex].number = this.value
  $('#coupleFields .nameInput').last().focusout ->
    couples[thisIndex].name = this.value

removeCouple = ->
  return if couples.length < 1

  couples.pop()
  $('#coupleFields div:last').remove()

addJudge = ->
  newDivContent = '<div><input type="text" class="numberInput">'
  newDivContent += '<input type="text" class="nameInput">'
  newDivContent += '<br /></div>'
  $('#judgeFields').append newDivContent

  judges.push {number: "", name: ""}

  thisIndex = judges.length - 1
  $('#judgeFields .numberInput').last().focusout ->
    judges[thisIndex].number = this.value
  $('#judgeFields .nameInput').last().focusout ->
    judges[thisIndex].name = this.value

removeJudge = ->
  return if judges.length < 1

  judges.pop()
  $('#judgeFields div:last').remove()

addDance = ->
  newDivContent = '<div><input type="text" class="numberInput">'
  newDivContent += '<input type="text" class="nameInput">'
  newDivContent += '<br /></div>'
  $('#danceFields').append newDivContent

  dances.push {number: "", name: ""}

  thisIndex = dances.length - 1
  $('#danceFields .numberInput').last().focusout ->
    dances[thisIndex].number = this.value
  $('#danceFields .nameInput').last().focusout ->
    dances[thisIndex].name = this.value

removeDance = ->
  return if dances.length < 1

  dances.pop()
  $('#danceFields div:last').remove()

generateMarks = ->
  return if couples.length < 1 or judges.length < 1 or dances.length < 1

  $('#marks').empty()
  for dance in dances
    newTable = '<div><h3>' + dance.name + '</h3>'
    newTable += '<table><tr><th></th>'
    for judge in judges
      newTable += '<th>' + judge.number + '</th>'
    newTable += '</tr>'
    for couple in couples
      newTable += '<tr><td>' + couple.number + '</td>'
      for judge in judges
        newTable += '<td><input type="text"></td>'
    newTable += '<br /></div>'
    $('#marks').append newTable
