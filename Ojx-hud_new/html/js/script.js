
window.addEventListener('message', function (eventData) {
    const actionData = eventData.data;
    if (actionData.action === true) {
        switch (actionData.type) {
            case 'OjxBurritosHud':
                ShowOjxBurritosHud(actionData);
            break;
            case 'CarHud':
                ShowCarHud(actionData);
            break;
        }
    } else if (!actionData.action) {
        HideHud();
    }
});

function HideHud() {
    $(".hud_warp").fadeOut(1);
}

function ShowOjxBurritosHud(actionData) {
    $(".hud_warp").fadeIn(1);
    $(".carhud_fucknil").fadeOut(350)
    var compass = actionData.compass;
    
    if (actionData.voice == true) {
        $('.ojxlinefull').css('width', '100%')
    } else {
        $('.ojxlinefull').css('width', '0%')
    }
    
    $('.as').text(Math.floor(actionData.health) + '%');
    $('.ass').text(Math.floor(actionData.armour) + '%');
    $('.asss').text(Math.floor(actionData.food) + '%');
    $('.assss').text(Math.floor(actionData.thirst) + '%');
    $('.asssss').text(Math.floor(actionData.stress) + '%')
    
    $('#fuck').text(actionData.ojxass)
    $('#compastext').text(compass);
    $('.ojxstaminalinefull').css('width', actionData.stamina+'%')
}

function ShowCarHud(actionData) {
    $(".hud_warp").fadeIn(1);
    $(".carhud_fucknil").fadeIn(350)
    var compass = actionData.compass;
    var seatbeltValue = Math.floor(actionData.seatbelt);
    
    if (actionData.voice == true) {
        $('.ojxlinefull').css('width', '100%')
    } else {
        $('.ojxlinefull').css('width', '0%')
    }
    
    $('.as').text(Math.floor(actionData.health) + '%');
    $('.ass').text(Math.floor(actionData.armour) + '%');
    $('.asss').text(Math.floor(actionData.food) + '%');
    $('.assss').text(Math.floor(actionData.thirst) + '%');
    $('.asssss').text(Math.floor(actionData.stress) + '%')

    $('#cartext').text(Math.floor(actionData.vehspeed) + 'KMH')
    $('#fueltext').text(Math.floor(actionData.fuel) + '% Fuel')
    
    $('#fuck').text(actionData.ojxass)
    $('#belticon').text(seatbeltValue);

    if (seatbeltValue === 1) {
        $('#belticon').text('');
    } else if (seatbeltValue === 0) {
        $('#belticon').text('');
    }
    
    if (seatbeltValue === 1) {
       $('#belticon').css('color', 'white');
    } else {
        $('#belticon').css('color', '#00000096'); 
    }
    
    $('#compastext').text(compass);
    $('.ojxstaminalinefull').css('width', actionData.stamina+'%')
}