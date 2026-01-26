const gapOptions = 5;
const buttonCenter = 45 / 2;
let options = [];

function createOptionsElements(selectOption) {
    const $container = $('#options-container').empty();
    $("#interaction-container").css('visibility', 'hidden');
    $('.option').css('transition', 'none');

    options.forEach((option, index) => {
        const optionId = `option${index + 1}`;

        const $option = $('<div></div>', {
            id: optionId,
            class: index == 0 ? "option active" : index === 1 ? "option" : "option hidden"
        });

        const $icon = $('<i></i>', {
            class: option.icon
        });

        const $text = $('<p></p>', {
            class: 'option-text',
            text: option.label
        });

        $option.append($icon);
        $option.append($text);

        $container.append($option);

        const adjustTransform = () => {
            if (index === 0) {
                const optionHeight = $option.outerHeight();
                $option.css('transform', `translateY(-${(optionHeight / 2) - buttonCenter}px)`);
            } else if (index === 1) {
                const currentOptionHeight = $(`#option1`).outerHeight();
                const optionHeight = $option.outerHeight();
                $option.css('transform', `translateY(-${((currentOptionHeight / 2) - buttonCenter) + optionHeight + gapOptions}px)`);
            } else if (index != 0 && index != 1) {
                const optionHeight = $option.outerHeight();
                const prevOptionHeight = $(`#option${index}`).outerHeight();
                const prevPrevOptionHeight = $(`#option${index - 1}`).outerHeight();
                $option.css('transform', `translateY(-${(((prevPrevOptionHeight / 2) - buttonCenter) + gapOptions) + (prevOptionHeight + gapOptions) + optionHeight}px)`);
            }

            if (options.length === index + 1) {
                setTimeout(() => {
                    $('.option').css({
                        'transition': 'transform 0.5s ease, background-color 0.5s ease, opacity 0.5s ease'
                    });
                }, 100);
            }
        };
 
        const checkAndAdjustTransform = (prevHeight = 0, attempts = 0) => {
            const currentHeight = $option.outerHeight();
            if (currentHeight > prevHeight || attempts < 10) {
                requestAnimationFrame(() => checkAndAdjustTransform(currentHeight, attempts + 1));
            } else {
                adjustTransform();
            }
        };

        requestAnimationFrame(() => {
            requestAnimationFrame(() => checkAndAdjustTransform());
        });
    });

    setupKeyButton();
    setupScrollDesign();

    setTimeout(() => {
        setInteractionCenter();
        $("#interaction-container").css('visibility', 'visible');

        if (selectOption > 1) {
            for (let i = 0; i < (selectOption - 1); i++) {
                scrollUpOption();
            }
        } 
    }, 100);
}

function setInteractionCenter() {
    var maxWidth = 0;
    var widthWithPaddings = 0;

    $('#options-container .option').each(function() {
        var optionWidth = $(this).width();
        if (optionWidth > maxWidth) {
            maxWidth = optionWidth;
            widthWithPaddings = $(this).outerWidth();
        }
    });

    $('#options-container .option').width(maxWidth);

    var optionAvgWidth = widthWithPaddings / 2
    $('#options-container').css('left', `-${optionAvgWidth}px`);
    $('#options-container').css('top', `5px`);
    $('#button').css('left', `-${optionAvgWidth + 45 + 45}px`); // 45 button width / 20 margin 
    $('#scroll-icons').css('right', `-${optionAvgWidth + 10}px`); // 10 margin
}

let actualOption = 1;
function scrollDownOption() {
    const prevOptionHeight = $(`#option${actualOption - 1}`).outerHeight();
    const currentOptionHeight = $(`#option${actualOption}`).outerHeight();
    const nextOptionHeight = $(`#option${actualOption + 1}`).outerHeight();

    if (actualOption > 1) { // Down Scroll
        resetProgress();

        $('.fa-caret-down').addClass('transform-scale-down').one('transitionend', function() {
            $(this).removeClass('transform-scale-down');
        });

        const optionAbove = (((prevOptionHeight / 2) - buttonCenter) + gapOptions) + (currentOptionHeight + gapOptions) + nextOptionHeight;
        $(`#option${actualOption + 1}`).css('transform', `translateY(-${optionAbove}px)`).addClass('hidden');
        const optionCenter = (((prevOptionHeight / 2) - buttonCenter) + gapOptions) + currentOptionHeight;
        $(`#option${actualOption}`).css('transform', `translateY(-${optionCenter}px)`).removeClass('active');
        const optionBelow = Math.abs(((prevOptionHeight / 2) - buttonCenter))
        $(`#option${actualOption - 1}`).css('transform', `translateY(-${optionBelow}px)`).addClass('active');
        const optionBelowBelow = (((prevOptionHeight / 2) + buttonCenter) + gapOptions);
        $(`#option${actualOption - 2}`).css('transform', `translateY(${optionBelowBelow}px)`).removeClass('hidden');
        $('.fa-caret-down').removeClass('active');

        actualOption--;

        setupKeyButton();
        setupScrollDesign();
    }
}

function scrollUpOption() {
    const currentOptionHeight = $(`#option${actualOption}`).outerHeight();
    const nextOptionHeight = $(`#option${actualOption + 1}`).outerHeight();
    const nextNextOptionHeight = $(`#option${actualOption + 2}`).outerHeight();

    if (actualOption < options.length) { // Up Scroll
        resetProgress();

        $('.fa-caret-up').addClass('transform-scale-down').one('transitionend', function() {
            $(this).removeClass('transform-scale-down');
        });

        const optionBelow = (((nextOptionHeight / 2) + buttonCenter) + gapOptions) + (currentOptionHeight + gapOptions);
        $(`#option${actualOption - 1}`).css('transform', `translateY(${optionBelow}px)`).addClass('hidden');
        const optionCenter = ((nextOptionHeight / 2) + buttonCenter) + gapOptions;
        $(`#option${actualOption}`).css('transform', `translateY(${optionCenter}px)`).removeClass('active');
        const optionAbove = Math.abs(((nextOptionHeight / 2) - buttonCenter))
        $(`#option${actualOption + 1}`).css('transform', `translateY(-${optionAbove}px)`).addClass('active');
        const optionAboveAbove = (((nextOptionHeight / 2) - buttonCenter) + gapOptions) + nextNextOptionHeight;
        $(`#option${actualOption + 2}`).css('transform', `translateY(-${optionAboveAbove}px)`).removeClass('hidden');

        actualOption++;

        setupKeyButton();
        setupScrollDesign();
    }
}

function setupScrollDesign() {
    if (options.length < 2) {
        $("#scroll-icons").css('display', 'none');
        return
    }

    $("#scroll-icons").css('display', 'flex');

    if (actualOption < options.length) {
        $('.fa-caret-up').addClass('active');
    } else {
        $('.fa-caret-up').removeClass('active');
    }

    if (actualOption > 1) {
        $('.fa-caret-down').addClass('active');
    } else {
        $('.fa-caret-down').removeClass('active');
    }
}

function hexToRGBA(hex, alpha = 0.75) {
    hex = hex.replace(/^#/, '');

    if (hex.length === 3) {
        hex = hex.split('').map(function (hexChar) {
            return hexChar + hexChar;
        }).join('');
    }

    var r = parseInt(hex.substring(0, 2), 16);
    var g = parseInt(hex.substring(2, 4), 16);
    var b = parseInt(hex.substring(4, 6), 16);

    return `rgba(${r}, ${g}, ${b}, ${alpha})`;
}

var elementType = "interaction";
function setupKeyButton() {
    if (elementType == "interaction") {
        $("#button").css("display", "flex");
        $(`#button-key`).text(options[actualOption - 1].key);
    } else {
        $("#button").css("display", "none");
    }
}

var progressAnimation = null;
var progressDuration = 1500; 
var progressCurrentHeight = 0;

function startProgress() {
    var $progressFill = $('#progress-fill');
    var buttonHeight = $('#button').outerHeight();

    $progressFill.css({
        'height': progressCurrentHeight + '%'
    });

    var remainingDuration = ((100 - progressCurrentHeight) / 100) * progressDuration; 
    
    progressAnimation = $({ height: progressCurrentHeight }).animate({ height: 100 }, {
        duration: remainingDuration,
        step: function(now) {
            progressCurrentHeight = now;
            $progressFill.css('height', now + '%');
        },
        easing: 'linear',
        complete: function() {
            resetProgress();
            $.post(`https://nn_interaction/progressSuccess`, JSON.stringify({interaction: interactionData, optionNumber: actualOption}))
        }
    });
}

function resetProgress() {
    if (progressAnimation) {
        var $progressFill = $('#progress-fill');

        progressAnimation.stop();
        progressAnimation = null;

        progressCurrentHeight = 0;
        $progressFill.css('height', '0%');
        return
    }
}

$(document).ready(function() {
    window.addEventListener('message', function(event) {
        let data = event.data;

        switch (data.action) {
            case 'createElements':
                elementType = data.style;
                options = data.options;
                interactionData = data.interaction;
                actualOption = 1;

                createOptionsElements(data.selectOption);
                break
            case 'removeElements':
                $('#options-container').empty();
                $("#interaction-container").css('visibility', 'hidden');
            case 'scrollUpOption':
                scrollDownOption();
                break
            case 'scrollDownOption':
                scrollUpOption();
                break
            case 'progressStart':
                progressDuration = data.duration;
                startProgress();
                break
            case 'progressReset':
                resetProgress();
                break
        }
    });
});
