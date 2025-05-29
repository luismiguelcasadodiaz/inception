#!/bin/bash
echo "Pushing to origin in GitHub..."
git push origin main
echo "Pushing to delivery in 42 ..."
git push delivery main
