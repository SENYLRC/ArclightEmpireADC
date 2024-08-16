// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import bootstrap from "bootstrap"
import githubAutoCompleteElement from "@github/auto-complete-element"
import Blacklight from "blacklight"

import "arclight"

// Remove dashes from the autocomplete options
document.addEventListener('DOMContentLoaded', function() {
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
});
