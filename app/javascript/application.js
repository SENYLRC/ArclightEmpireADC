import "@hotwired/turbo-rails"
import "controllers"
import bootstrap from "bootstrap"
import githubAutoCompleteElement from "@github/auto-complete-element"
import Blacklight from "blacklight"
import "arclight"

function initializeAutocompleteObserver() {
    const observer = new MutationObserver(function(mutations) {
        mutations.forEach(function(mutation) {
            if (mutation.type === 'childList' && mutation.addedNodes.length > 0) {
                mutation.addedNodes.forEach(function(node) {
                    if (node.nodeType === Node.ELEMENT_NODE && node.matches('li[role="option"]')) {
                        const span = node.querySelector('span');
                        if (span) {
                            span.textContent = span.textContent.replace(/-/g, ' ');
                        }
                    }
                });
            }
        });
    });

    const targetNode = document.getElementById('autocomplete-popup');
    if (targetNode) {
        observer.observe(targetNode, { childList: true, subtree: true });
    }
}

// Run the function when the page is initially loaded
document.addEventListener('DOMContentLoaded', initializeAutocompleteObserver);

// Run the function on every Turbo visit
document.addEventListener('turbo:load', initializeAutocompleteObserver);
